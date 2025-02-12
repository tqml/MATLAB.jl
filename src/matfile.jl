# mat file open & close


const matfile_modes = Set{String}(["r", "w", "w4", "w7.3", "u"])

"""
Open a MAT-file "filename" using mode "mode". 

Current valid entries for "mode" are
 * "r"    == read only.
 * "w"    == write only (deletes any existing file with name <filename>).
 * "w4"   == as "w", but create a MATLAB 4.0 MAT-file.
 * "w7.3" == as "w", but create a MATLAB 7.3 MAT-file.
 * "u"    == update.  Read and write allowed, existing file is not deleted.
"""
mutable struct MatFile
    ptr::Ptr{Cvoid}
    filename::String
    mode::String

    function MatFile(filename::AbstractString, mode::AbstractString)
        if !(mode in matfile_modes)
            throw(MEngineError("invalid mode '$(mode)', must be one of $(join(matfile_modes, ", "))"))
        end
        p = mat_open(filename, mode)
        if p == C_NULL
            throw(MatFileException("failed to open file $(filename)"))
        end
        mat_get_errno(p) != 0 && throw(MatFileException("failed to open file $(filename)"))
        self = new(p, filename, mode)
        finalizer(release, self)
        return self
    end
end
MatFile(filename) = MatFile(filename, "r")

filename(f::MatFile) = getfield(f, :filename)
get_ptr(f::MatFile) = getfield(f, :ptr)
mode(f::MatFile) = getfield(f, :mode)

function unsafe_convert(::Type{Ptr{Cvoid}}, f::MatFile)
    ptr = get_ptr(f)
    ptr == C_NULL && throw(UndefRefError())
    return ptr
end

function release(f::MatFile)
    ptr = get_ptr(f)
    if ptr != C_NULL
        mat_close(ptr)
    end
    setfield!(f, :ptr, C_NULL)
    return nothing
end

function close(f::MatFile)
    ret = mat_close(f)
    ret != 0 && throw(MEngineError("failed to close file (err = $ret)"))
    setfield!(f, :ptr, C_NULL)
    return nothing
end



Base.isreadonly(f::MatFile) = mode(f) == "r"

# get & put variables

function get_mvariable(f::MatFile, name::String)
    pm = mat_get_variable(f, name)
    pm == C_NULL && error("Attempt to get variable '$(name)' failed.")
    return MxArray(pm)
end

get_mvariable(f::MatFile, name::Symbol) = get_mvariable(f, string(name))

get_variable(f::MatFile, name::String) = jvalue(get_mvariable(f, name))
get_variable(f::MatFile, name::Symbol) = jvalue(get_mvariable(f, name))

function put_variable(f::MatFile, name::String, v::MxArray)
    ret = mat_put_variable(f, name, v)
    ret != 0 && error("Attempt to put variable $(name) failed.")
    return nothing
end

put_variable(f::MatFile, name::Symbol, v::MxArray) = put_variable(f, string(name), v)

put_variable(f::MatFile, name::String, v) = put_variable(f, name, mxarray(v))
put_variable(f::MatFile, name::Symbol, v) = put_variable(f, name, mxarray(v))

# operation over entire file

function put_variables(f::MatFile; kwargs...)
    for (name, val) in kwargs
        put_variable(f, name, val)
    end
end


delete_variable(f::MatFile, name::Symbol) = delete_variable(f, string(name))
function delete_variable(f::MatFile, name::AbstractString)
    ret = mat_delete_variable(f, name)
    if ret != 0
        throw(MatFileException("failed to delete variable '$(name)'"))
    end
    return nothing
end

function write_matfile(filename::String; kwargs...)
    mf = MatFile(filename, "w")
    put_variables(mf; kwargs...)
    close(mf)
    return
end

function variable_names(f::MatFile)
    # get a list of all variable names
    _n = Ref{Cint}()
    _a = mat_get_dir(f, _n)
    n = Int(_n[])

    if n < 0
        throw(MatFileException("failed to get variable names"))
    end

    if n == 0 || _a == C_NULL
        # no variables in file
        return String[]
    end

    a = unsafe_wrap(Array, _a, (n,))
    names = String[unsafe_string(s) for s in a]
    mx_free(_a)
    return names
end

function read_matfile(f::MatFile)
    # return a dictionary of all variables
    names = variable_names(f)
    r = Dict{String, MxArray}()
    sizehint!(r, length(names))
    for nam in names
        r[nam] = get_mvariable(f, nam)
    end
    return r
end

function read_matfile(filename)
    f = MatFile(String(filename), "r")
    r = read_matfile(f)
    close(f)
    return r
end



# %% --- Extra Propertynames ------------------------------------------ #


function Base.getproperty(matfile::MatFile, name::Symbol)
    if name == :filename || name == :ptr || name == :mode
        return getfield(matfile, name)
    else
        return get_variable(matfile, name)
    end
end


function Base.propertynames(matfile::MatFile, private::Bool = false)
    names = [Symbol(name) for name in variable_names(matfile)]
    if private
        return [:filename, :ptr, names...]
    end
    return names
end


Base.keys(f::MatFile) = variable_names(f)
Base.getindex(matfile::MatFile, name::AbstractString) = get_variable(matfile, name)
Base.setindex!(matfile::MatFile, v, name::AbstractString) = put_variable(matfile, name, v)

# %% --- Info ------------------------------------------ #

"""
MxArrayHeader provides information about a MxArray object without having
to load the entire object from the MAT-file.
"""
struct MxArrayHeader
    ptr::Ptr{Cvoid}
end

function unsafe_convert(::Type{Ptr{Cvoid}}, m::MxArrayHeader)
    ptr = m.ptr
    if ptr == C_NULL
        throw(UndefRefError())
    end
    return ptr
end

classid(m::MxArrayHeader) = mxClassID(mx_get_classid(m))
eltype(m::MxArrayHeader) = mxclassid_to_type(mxclassid(m))

nrows(mx::MxArrayHeader)  = convert(Int, mx_get_m(mx))
ncols(mx::MxArrayHeader)  = convert(Int, mx_get_n(mx))
nelems(mx::MxArrayHeader) = convert(Int, mx_get_nelems(mx))
ndims(mx::MxArrayHeader)  = convert(Int, mx_get_ndims(mx))

is_numeric(mx::MxArrayHeader) = Bool(mx_is_numeric(mx))
is_logical(mx::MxArrayHeader) = Bool(mx_is_logical(mx))
is_complex(mx::MxArrayHeader) = Bool(mx_is_complex(mx))
is_sparse(mx::MxArrayHeader)  = Bool(mx_is_sparse(mx))
is_struct(mx::MxArrayHeader)  = Bool(mx_is_struct(mx))
is_cell(mx::MxArrayHeader)    = Bool(mx_is_cell(mx))
is_char(mx::MxArrayHeader)    = Bool(mx_is_char(mx))
is_empty(mx::MxArrayHeader)   = Bool(mx_is_empty(mx))

function size(mx::MxArrayHeader)
    nd = ndims(mx)
    pdims::Ptr{mwSize} = mx_get_dims(mx)
    _dims = unsafe_wrap(Array, pdims, (nd,))
    dims = Vector{Int}(undef, nd)
    for i in 1:nd
        dims[i] = Int(_dims[i])
    end
    return tuple(dims...)
end

function size(mx::MxArrayHeader, d::Integer)
    d <= 0 && throw(ArgumentError("The dimension must be a positive integer."))
    nd = ndims(mx)
    if nd == 2
        d == 1 ? nrows(mx) : d == 2 ? ncols(mx) : 1
    else
        pdims::Ptr{mwSize} = mx_get_dims(mx)
        _dims = unsafe_wrap(Array, pdims, (nd,))
        d <= nd ? Int(_dims[d]) : 1
    end
end



function get_variable_info(matfile::MatFile, name::AbstractString)
    p = mat_get_variable_info(matfile, name)
    p == C_NULL && throw(MatFileException("failed to get variable info for $(name)"))
    return MxArrayHeader(p)
end

function show_info(matfile::MatFile)
    matfile_filename = basename(matfile.filename)
    matfile_bytes = _byte_format(filesize(matfile.filename))
    names = variable_names(matfile)
    println("MAT-file: ", matfile_filename, " (", matfile_bytes, ")")
    for name in names
        info = get_variable_info(matfile, name)
        println("  ", name, " (", classid(info), ", ", size(info), ")")
    end
end



function _byte_format(bytes::Integer)
    if bytes < 1024
        return "$bytes B"
    elseif bytes < 1024^2
        return "$(round(bytes/1024, digits=2)) KiB"
    elseif bytes < 1024^3
        return "$(round(bytes/1024^2, digits=2)) MiB"
    else
        return "$(round(bytes/1024^3, digits=2)) GiB"
    end
end


