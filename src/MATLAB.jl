module MATLAB

using Libdl
using SparseArrays

import Base: eltype, close, size, copy, ndims, unsafe_convert

# mxarray
export MxArray, mxClassID, mxComplexity,
       mxclassid, data_ptr,
       classid, nrows, ncols, nelems, elsize

export is_double, is_single,
       is_int8, is_uint8, is_int16, is_uint16,
       is_int32, is_uint32, is_int64, is_uint64,
       is_numeric, is_complex, is_sparse, is_empty,
       is_logical, is_char, is_struct, is_cell

export mxarray, mxsparse, delete,
       mxcellarray, get_cell, set_cell,
       mxstruct, mxstructarray, mxnfields, get_fieldname, get_field, set_field,
       jvalue, jarray, jscalar, jvector, jmatrix, jsparse, jstring, jdict

# engine & matfile
export MSession, MatFile,
       get_default_msession, restart_default_msession, close_default_msession,
       eval_string, get_mvariable, get_variable, put_variable, put_variables,
       variable_names, read_matfile, write_matfile,
       mxcall,
       @mput, @mget, @mat_str

if Sys.iswindows()
    export show_msession, hide_msession, get_msession_visiblity
end

const depsfile = joinpath(dirname(@__DIR__), "deps", "deps.jl")
if isfile(depsfile)
    include(depsfile)
else
    error("MATLAB is not properly installed. Please run Pkg.build(\"MATLAB\") and restart Julia.")
end

include("exceptions.jl")
include("init.jl") # initialize Refs
include("mxarray.jl")
include("matfile.jl")
include("engine.jl")
include("matstr.jl")

if Sys.iswindows()
    # workaround "primary message table for module 77" error
    # creates a dummy Engine session and keeps it open so the libraries used by all other
    # Engine clients are not loaded and unloaded repeatedly
    # see: https://www.mathworks.com/matlabcentral/answers/305877-what-is-the-primary-message-table-for-module-77

    # initialization is delayed until first call to MSession
    const persistent_msession_ref = Ref{MSession}()
    const persistent_msession_assigned = Ref(false)

    function assign_persistent_msession()
        if persistent_msession_assigned[] == false
            persistent_msession_assigned[] = true
            persistent_msession_ref[] = MSession(0)
        end
    end
end



function __init__()

    @info "MATLAB Debug Info" matlab_cmd matlab_libpath

    # load libraries
    # workaround for https://github.com/JuliaInterop/MATLAB.jl/issues/200
    if Sys.iswindows()
        ENV["PATH"] = string(matlab_libpath, ";", ENV["PATH"])
    elseif Sys.islinux()
        ENV["PATH"] = string(matlab_libpath, ":", ENV["PATH"])
    end

end


###########################################################
#
#   deprecations
#
###########################################################


end
