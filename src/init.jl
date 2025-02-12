# libraries

#const _libeng = Ref{Ptr{Cvoid}}()
#const libmx  = Ref{Ptr{Cvoid}}()
#const libmat = Ref{Ptr{Cvoid}}()

if haskey(ENV, "MATLAB_LIB_PATH")
    _matlab_libpath = ENV["MATLAB_LIB_PATH"]
else
    _matlab_libpath = matlab_libpath
end

#get(ENV, "MATLAB.jl")

const libeng = joinpath(_matlab_libpath, "libeng")
const libmat = joinpath(_matlab_libpath, "libmat")
const libmx = joinpath(_matlab_libpath, "libmx")

# MATLAB types
const engine_handle = Ptr{Cvoid}
const mxarray_handle = Ptr{Cvoid}
const mwSize = UInt
const mwIndex = Int
#const mwSize = Cint
#const mwIndex = Cint


# matlab engine functions

"""
    eng_open(command)

Start matlab process
"""
function eng_open(command)
    return ccall((:engOpen, libeng), engine_handle, (Cstring,), command)
end

"""
    eng_close(handle)

Close down matlab server
"""
function eng_close(handle)
    return ccall((:engClose, libeng), Cint, (engine_handle,), handle)
end

function eng_set_visible(handle, visible)
    return ccall((:engSetVisible, libeng), Cint, (engine_handle, Cint), handle, visible)
end

function eng_get_visible(handle, visible_ref)
    return ccall((:engGetVisible, libeng), Cint, (engine_handle, Ref{Cint}), handle, visible_ref)
end

"""
    eng_output_buffer(handle, buf, buf_len)

Register a buffer to hold matlab text output
"""
function eng_output_buffer(handle, buf, buf_len)
    return ccall((:engOutputBuffer, libeng), Cint, (engine_handle, Ptr{UInt8}, Cint), handle, buf, buf_len)
end

"""
    eng_eval_string(handle, s)

Execute matlab statement
"""
function eng_eval_string(handle, s)
    return ccall((:engEvalString, libeng), Cint, (engine_handle, Cstring), handle, s)
end

"""
    eng_put_variable(handle, name, array_handle)

Put a variable into MATLAB's workspace with the specified name
"""
function eng_put_variable(handle, name, array_handle)
    return ccall((:engPutVariable, libeng), Cint, (Ptr{Cvoid}, Cstring, Ptr{Cvoid}), handle, name, array_handle)
end

"""
    eng_get_variable(handle, name)

Get a variable with the specified name from MATLAB's workspace
"""
function eng_get_variable(handle, name)
    return ccall((:engGetVariable, libeng), mxarray_handle, (Ptr{Cvoid}, Cstring), handle, name)
end

# mxarray functions

function mx_destroy_array(array)
    return ccall((:mxDestroyArray, libmx), Cvoid, (mxarray_handle,), array)
end

function mx_duplicate_array(array)
    return ccall((:mxDuplicateArray, libmx), mxarray_handle, (mxarray_handle,), array)
end

# functions to access mxarray

function mx_free(array)
    return ccall((:mxFree, libmx), Cvoid, (Ptr{Cvoid},), array)
end

function mx_get_classid(array)
    return ccall((:mxGetClassID, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_get_m(array)
    return ccall((:mxGetM, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_get_n(array)
    return ccall((:mxGetN, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_get_nelems(array)
    return ccall((:mxGetNumberOfElements, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_get_ndims(array)
    return ccall((:mxGetNumberOfDimensions_730, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_get_elemsize(array)
    return ccall((:mxGetElementSize, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_get_data(array)
    return ccall((:mxGetData, libmx), Ptr{Cvoid}, (Ptr{Cvoid},), array)
end

function mx_get_dims(array)
    return ccall((:mxGetDimensions_730, libmx), Ptr{Cint}, (Ptr{Cvoid},), array)
end

function mx_get_nfields(array)
    return ccall((:mxGetNumberOfFields, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_get_pr(array)
    return ccall((:mxGetPr, libmx), Ptr{Cvoid}, (Ptr{Cvoid},), array)
end

function mx_get_pi(array)
    return ccall((:mxGetPi, libmx), Ptr{Cvoid}, (Ptr{Cvoid},), array)
end

function mx_get_ir(array)
    return ccall((:mxGetIr_730, libmx), Ptr{mwIndex}, (Ptr{Cvoid},), array)
end

function mx_get_jc(array)
    return ccall((:mxGetJc_730, libmx), Ptr{mwIndex}, (Ptr{Cvoid},), array)
end

function mx_is_double(array)
    return ccall((:mxIsDouble, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_single(array)
    return ccall((:mxIsSingle, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_int64(array)
    return ccall((:mxIsInt64, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_uint64(array)
    return ccall((:mxIsUint64, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_int32(array)
    return ccall((:mxIsInt32, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_uint32(array)
    return ccall((:mxIsUint32, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_int16(array)
    return ccall((:mxIsInt16, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_uint16(array)
    return ccall((:mxIsUint16, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_int8(array)
    return ccall((:mxIsInt8, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_uint8(array)
    return ccall((:mxIsUint8, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_char(array)
    return ccall((:mxIsChar, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_numeric(array)
    return ccall((:mxIsNumeric, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_logical(array)
    return ccall((:mxIsLogical, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_complex(array)
    return ccall((:mxIsComplex, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_sparse(array)
    return ccall((:mxIsSparse, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_empty(array)
    return ccall((:mxIsEmpty, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_struct(array)
    return ccall((:mxIsStruct, libmx), Cint, (Ptr{Cvoid},), array)
end

function mx_is_cell(array)
    return ccall((:mxIsCell, libmx), Cint, (Ptr{Cvoid},), array)
end

# functions to create & delete MATLAB arrays

function mx_create_numeric_matrix(m, n, classid, complexflag)
    return ccall((:mxCreateNumericMatrix_730, libmx), Ptr{Cvoid}, (Cint, Cint, Cint, Cint), m, n, classid, complexflag)
end

function mx_create_numeric_array(ndim, dims, classid, complexflag)
    return ccall(
        (:mxCreateNumericArray_730, libmx),
        Ptr{Cvoid},
        (Cint, Ptr{Cint}, Cint, Cint),
        ndim,
        dims,
        classid,
        complexflag
    )
end

function mx_create_double_scalar(value)
    return ccall((:mxCreateDoubleScalar, libmx), Ptr{Cvoid}, (Cdouble,), value)
end

function mx_create_logical_scalar(value)
    return ccall((:mxCreateLogicalScalar, libmx), Ptr{Cvoid}, (Cint,), value)
end

function mx_create_sparse(m, n, nzmax, complexflag)
    return ccall((:mxCreateSparse_730, libmx), Ptr{Cvoid}, (Cint, Cint, Cint, Cint), m, n, nzmax, complexflag)
end

function mx_create_sparse_logical(m, n, nzmax)
    return ccall((:mxCreateSparseLogicalMatrix_730, libmx), Ptr{Cvoid}, (Cint, Cint, Cint), m, n, nzmax)
end

function mx_create_string(str)
    return ccall((:mxCreateString, libmx), Ptr{Cvoid}, (Cstring,), str)
end

function mx_create_char_array(ndim, dims)
    return ccall((:mxCreateCharArray_730, libmx), Ptr{Cvoid}, (Cint, Ptr{Cint}), ndim, dims)
end

function mx_create_cell_array(ndim, dims)
    return ccall((:mxCreateCellArray_730, libmx), Ptr{Cvoid}, (Cint, Ptr{Cint}), ndim, dims)
end

function mx_create_struct_matrix(m, n, nfields, fieldnames)
    return ccall(
        (:mxCreateStructMatrix_730, libmx),
        Ptr{Cvoid},
        (Cint, Cint, Cint, Ptr{Cstring}),
        m,
        n,
        nfields,
        fieldnames
    )
end

function mx_create_struct_array(ndim, dims, nfields, fieldnames)
    return ccall(
        (:mxCreateStructArray_730, libmx),
        Ptr{Cvoid},
        (Cint, Ptr{Cint}, Cint, Ptr{Cstring}),
        ndim,
        dims,
        nfields,
        fieldnames
    )
end

function mx_get_cell(array, index)
    return ccall((:mxGetCell_730, libmx), Ptr{Cvoid}, (Ptr{Cvoid}, Cint), array, index)
end

function mx_set_cell(array, index, value)
    return ccall((:mxSetCell_730, libmx), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Cvoid}), array, index, value)
end

function mx_get_field(array, index, fieldname)
    return ccall((:mxGetField_730, libmx), Ptr{Cvoid}, (Ptr{Cvoid}, Cint, Cstring), array, index, fieldname)
end

function mx_set_field(array, index, fieldname, value)
    return ccall(
        (:mxSetField_730, libmx),
        Cvoid,
        (Ptr{Cvoid}, Cint, Cstring, Ptr{Cvoid}),
        array,
        index,
        fieldname,
        value
    )
end

function mx_get_field_bynum(array, index, fieldnum)
    return ccall((:mxGetFieldByNumber_730, libmx), Ptr{Cvoid}, (Ptr{Cvoid}, Cint, Cint), array, index, fieldnum)
end

function mx_get_fieldname(array, index)
    return ccall((:mxGetFieldNameByNumber, libmx), Cstring, (Ptr{Cvoid}, Cint), array, index)
end

function mx_get_string(array, buf, buflen)
    return ccall((:mxGetString_730, libmx), Cint, (Ptr{Cvoid}, Ptr{UInt8}, Cint), array, buf, buflen)
end

# load I/O mat functions

const matError = Cint
const matfile_handle = Ptr{Cvoid}

function mat_open(filename, mode)
    return ccall((:matOpen, libmat), Ptr{Cvoid}, (Cstring, Cstring), filename, mode)
end

"""
Close a MAT-file opened with matOpen.
The pointer-to-MATfile argument is invalid, once matClose returns.
Return zero for success, EOF on error.
"""
function mat_close(matfile)
    return ccall((:matClose, libmat), Cint, (Ptr{Cvoid},), matfile)
end

"""
Read the array value for the specified variable name from a MAT-file.

Return NULL if an error occurs.
"""
function mat_get_variable(matfile, name)
    return ccall((:matGetVariable, libmat), Ptr{Cvoid}, (Ptr{Cvoid}, Cstring), matfile, name)
end

function mat_get_variable_info(matfile, name)
    return ccall((:matGetVariableInfo, libmat), mxarray_handle, (matfile_handle, Cstring), matfile, name)
end

function mat_put_variable(matfile, name, array)
    return ccall((:matPutVariable, libmat), Cint, (Ptr{Cvoid}, Cstring, Ptr{Cvoid}), matfile, name, array)
end

"""
Remove a variable with with the specified name from the MAT-file pMF.
 
Return zero on success, non-zero on error. 
"""
function mat_delete_variable(matfile, name)
    return ccall((:matDeleteVariable, libmat), matError, (matfile_handle, Cstring), matfile, name)
end

"""
Get a list of the names of the arrays in a MAT-file.
The array of strings returned by this function contains "num"
entries.  It is allocated with one call to mxCalloc, and so 
can (must) be freed with one call to mxFree.

If there are no arrays in the MAT-file, return value 
is NULL and num is set to zero.  If an error occurs,
return value is NULL and num is set to a negative number.
"""
function mat_get_dir(matfile, num)
    return ccall((:matGetDir, libmat), Ptr{Ptr{UInt8}}, (Ptr{Cvoid}, Ref{Cint}), matfile, num)
end

"""
Return zero if MATFile is successfully openedno error, nonzero value otherwise.
"""
function mat_get_errno(matfile)
    return ccall((:matGetErrno, libmat), matError, (Ptr{Cvoid},), matfile)
end

"""
Return the ANSI C FILE pointer obtained when the MAT-file was opened.
Warning: the FILE pointer may be NULL in the case of a MAT file format
that does not allow access to the raw file pointer.
"""
function mat_get_fp(matfile)
    return ccall((:matGetFp, libmat), Ptr{Cvoid}, (Ptr{Cvoid},), matfile)
end
