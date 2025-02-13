# libraries

if haskey(ENV, "MATLAB_LIB_PATH")
    _matlab_libpath = ENV["MATLAB_LIB_PATH"]
else
    _matlab_libpath = matlab_libpath
end

const libeng = joinpath(_matlab_libpath, "libeng")
const libmat = joinpath(_matlab_libpath, "libmat")
const libmx  = joinpath(_matlab_libpath, "libmx")

# MATLAB types
const engine_handle = Ptr{Cvoid}
const mxarray_handle = Ptr{Cvoid}
const mwSize = UInt # TODO change to Cint
const mwIndex = Int # TODO change to Cint


# matlab engine functions

eng_open(command)                            = ccall((:engOpen, libeng), engine_handle, (Cstring,), command)
eng_close(handle)                            = ccall((:engClose, libeng), Cint, (engine_handle,), handle)
eng_set_visible(handle, visible)             = ccall((:engSetVisible, libeng), Cint, (engine_handle, Cint), handle, visible)
eng_get_visible(handle, visible_ref)         = ccall((:engGetVisible, libeng), Cint, (engine_handle, Ref{Cint}), handle, visible_ref)
eng_output_buffer(handle, buf, buf_len)      = ccall((:engOutputBuffer, libeng), Cint, (engine_handle, Ptr{UInt8}, Cint), handle, buf, buf_len)
eng_eval_string(handle, s)                   = ccall((:engEvalString, libeng), Cint, (engine_handle, Cstring), handle, s)
eng_put_variable(handle, name, array_handle) = ccall((:engPutVariable, libeng), Cint, (engine_handle, Cstring, Ptr{Cvoid}), handle, name, array_handle)
eng_get_variable(handle, name)               = ccall((:engGetVariable, libeng), mxarray_handle, (engine_handle, Cstring), handle, name)

# mxarray functions

mx_destroy_array(array)   = ccall((:mxDestroyArray, libmx), Cvoid, (mxarray_handle,), array)
mx_duplicate_array(array) = ccall((:mxDuplicateArray, libmx), mxarray_handle, (mxarray_handle,), array)
mx_free(array)            = ccall((:mxFree, libmx), Cvoid, (Ptr{Cvoid},), array)

# functions to access mxarray

mx_get_classid(array)  = ccall((:mxGetClassID, libmx), Cint, (Ptr{Cvoid},), array)
mx_get_m(array)        = ccall((:mxGetM, libmx), Cint, (Ptr{Cvoid},), array)
mx_get_n(array)        = ccall((:mxGetN, libmx), Cint, (Ptr{Cvoid},), array)
mx_get_nelems(array)   = ccall((:mxGetNumberOfElements, libmx), Cint, (Ptr{Cvoid},), array)
mx_get_ndims(array)    = ccall((:mxGetNumberOfDimensions_730, libmx), Cint, (Ptr{Cvoid},), array)
mx_get_elemsize(array) = ccall((:mxGetElementSize, libmx), Cint, (Ptr{Cvoid},), array)
mx_get_data(array)     = ccall((:mxGetData, libmx), Ptr{Cvoid}, (Ptr{Cvoid},), array)
mx_get_dims(array)     = ccall((:mxGetDimensions_730, libmx), Ptr{Cint}, (Ptr{Cvoid},), array)
mx_get_nfields(array)  = ccall((:mxGetNumberOfFields, libmx), Cint, (Ptr{Cvoid},), array)
mx_get_pr(array)       = ccall((:mxGetPr, libmx), Ptr{Cvoid}, (Ptr{Cvoid},), array)
mx_get_pi(array)       = ccall((:mxGetPi, libmx), Ptr{Cvoid}, (Ptr{Cvoid},), array)
mx_get_ir(array)       = ccall((:mxGetIr_730, libmx), Ptr{mwIndex}, (Ptr{Cvoid},), array)
mx_get_jc(array)       = ccall((:mxGetJc_730, libmx), Ptr{mwIndex}, (Ptr{Cvoid},), array)


mx_is_double(array)  = ccall((:mxIsDouble, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_single(array)  = ccall((:mxIsSingle, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_int64(array)   = ccall((:mxIsInt64, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_uint64(array)  = ccall((:mxIsUint64, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_int32(array)   = ccall((:mxIsInt32, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_uint32(array)  = ccall((:mxIsUint32, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_int16(array)   = ccall((:mxIsInt16, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_uint16(array)  = ccall((:mxIsUint16, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_int8(array)    = ccall((:mxIsInt8, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_uint8(array)   = ccall((:mxIsUint8, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_char(array)    = ccall((:mxIsChar, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_numeric(array) = ccall((:mxIsNumeric, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_logical(array) = ccall((:mxIsLogical, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_complex(array) = ccall((:mxIsComplex, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_sparse(array)  = ccall((:mxIsSparse, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_empty(array)   = ccall((:mxIsEmpty, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_struct(array)  = ccall((:mxIsStruct, libmx), Bool, (Ptr{Cvoid},), array)
mx_is_cell(array)    = ccall((:mxIsCell, libmx), Bool, (Ptr{Cvoid},), array)

# functions to create & delete MATLAB arrays

mx_create_numeric_matrix(m, n, classid, complexflag)      = ccall((:mxCreateNumericMatrix_730, libmx), Ptr{Cvoid}, (Cint, Cint, Cint, Cint), m, n, classid, complexflag)
mx_create_numeric_array(ndim, dims, classid, complexflag) = ccall((:mxCreateNumericArray_730, libmx), Ptr{Cvoid}, (Cint, Ptr{Cint}, Cint, Cint), ndim, dims, classid, complexflag)
mx_create_double_scalar(value)                            = ccall((:mxCreateDoubleScalar, libmx), Ptr{Cvoid}, (Cdouble,), value)
mx_create_logical_scalar(value)                           = ccall((:mxCreateLogicalScalar, libmx), Ptr{Cvoid}, (Cint,), value)
mx_create_sparse(m, n, nzmax, complexflag)                = ccall((:mxCreateSparse_730, libmx), Ptr{Cvoid}, (Cint, Cint, Cint, Cint), m, n, nzmax, complexflag)
mx_create_sparse_logical(m, n, nzmax)                     = ccall((:mxCreateSparseLogicalMatrix_730, libmx), Ptr{Cvoid}, (Cint, Cint, Cint), m, n, nzmax)
mx_create_string(str)                                     = ccall((:mxCreateString, libmx), Ptr{Cvoid}, (Cstring,), str)
mx_create_char_array(ndim, dims)                          = ccall((:mxCreateCharArray_730, libmx), Ptr{Cvoid}, (Cint, Ptr{Cint}), ndim, dims)
mx_create_cell_array(ndim, dims)                          = ccall((:mxCreateCellArray_730, libmx), Ptr{Cvoid}, (Cint, Ptr{Cint}), ndim, dims)
mx_create_struct_matrix(m, n, nfields, fieldnames)        = ccall((:mxCreateStructMatrix_730, libmx), Ptr{Cvoid}, (Cint, Cint, Cint, Ptr{Cstring}), m, n, nfields, fieldnames)
mx_create_struct_array(ndim, dims, nfields, fieldnames)   = ccall((:mxCreateStructArray_730, libmx), Ptr{Cvoid}, (Cint, Ptr{Cint}, Cint, Ptr{Cstring}), ndim, dims, nfields, fieldnames)


mx_get_cell(array, index)                    = ccall((:mxGetCell_730, libmx), Ptr{Cvoid}, (Ptr{Cvoid}, Cint), array, index)
mx_set_cell(array, index, value)             = ccall((:mxSetCell_730, libmx), Cvoid, (Ptr{Cvoid}, Cint, Ptr{Cvoid}), array, index, value)
mx_get_field(array, index, fieldname)        = ccall((:mxGetField_730, libmx), Ptr{Cvoid}, (Ptr{Cvoid}, Cint, Cstring), array, index, fieldname)
mx_set_field(array, index, fieldname, value) = ccall((:mxSetField_730, libmx), Cvoid, (Ptr{Cvoid}, Cint, Cstring, Ptr{Cvoid}), array, index, fieldname, value)
mx_get_field_bynum(array, index, fieldnum)   = ccall((:mxGetFieldByNumber_730, libmx), Ptr{Cvoid}, (Ptr{Cvoid}, Cint, Cint), array, index, fieldnum)
mx_get_fieldname(array, index)               = ccall((:mxGetFieldNameByNumber, libmx), Cstring, (Ptr{Cvoid}, Cint), array, index)
mx_get_string(array, buf, buflen)            = ccall((:mxGetString_730, libmx), Cint, (Ptr{Cvoid}, Ptr{UInt8}, Cint), array, buf, buflen)

# load I/O mat functions

const matError       = Cint
const matfile_handle = Ptr{Cvoid}

mat_open(filename, mode) = ccall((:matOpen, libmat), Ptr{Cvoid}, (Cstring, Cstring), filename, mode)

"""
Close a MAT-file opened with matOpen.
The pointer-to-MATfile argument is invalid, once matClose returns.
Return zero for success, EOF on error.
"""
mat_close(matfile) = ccall((:matClose, libmat), Cint, (Ptr{Cvoid},), matfile)

"""Read the array value for the specified variable name from a MAT-file. Return NULL if an error occurs."""
mat_get_variable(matfile, name) = ccall((:matGetVariable, libmat), Ptr{Cvoid}, (Ptr{Cvoid}, Cstring), matfile, name)

"""Read the array header for the specified variable name from a MAT-file. Return NULL if an error occurs. An array header must never be used to access the data in the array."""
mat_get_variable_info(matfile, name) = ccall((:matGetVariableInfo, libmat), mxarray_handle, (matfile_handle, Cstring), matfile, name)
mat_put_variable(matfile, name, array) = ccall((:matPutVariable, libmat), Cint, (Ptr{Cvoid}, Cstring, Ptr{Cvoid}), matfile, name, array)

"""
Remove a variable with with the specified name from the MAT-file pMF.
 
Return zero on success, non-zero on error. 
"""
mat_delete_variable(matfile, name) = ccall((:matDeleteVariable, libmat), matError, (matfile_handle, Cstring), matfile, name)

"""
Get a list of the names of the arrays in a MAT-file.
The array of strings returned by this function contains "num"
entries.  It is allocated with one call to mxCalloc, and so 
can (must) be freed with one call to mxFree.

If there are no arrays in the MAT-file, return value 
is NULL and num is set to zero.  If an error occurs,
return value is NULL and num is set to a negative number.
"""
mat_get_dir(matfile, num) = ccall((:matGetDir, libmat), Ptr{Ptr{UInt8}}, (Ptr{Cvoid}, Ref{Cint}), matfile, num)

"""
Return zero if MATFile is successfully openedno error, nonzero value otherwise.
"""
mat_get_errno(matfile) = ccall((:matGetErrno, libmat), matError, (Ptr{Cvoid},), matfile)

"""
Return the ANSI C FILE pointer obtained when the MAT-file was opened.
Warning: the FILE pointer may be NULL in the case of a MAT file format
that does not allow access to the raw file pointer.
"""
mat_get_fp(matfile) = ccall((:matGetFp, libmat), Ptr{Cvoid}, (Ptr{Cvoid},), matfile)
