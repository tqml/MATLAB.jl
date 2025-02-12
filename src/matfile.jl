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
