import Libdl

const depsfile = joinpath(@__DIR__, "deps.jl")

function find_matlab_root()
    # Determine MATLAB library path and provide facilities to load libraries with this path
    matlab_root = get(ENV, "MATLAB_ROOT",
        get(ENV, "MATLAB_HOME", nothing))
    if isnothing(matlab_root)
        matlab_exe = Sys.which("matlab")
        if !isnothing(matlab_exe)
            matlab_exe = islink(matlab_exe) ? readlink(matlab_exe) : matlab_exe # guard against /usr/local 
            matlab_root = dirname(dirname(matlab_exe))
        else
            if Sys.isapple()
                default_dir = "/Applications"
                if isdir(default_dir)
                    dirs = readdir(default_dir)
                    filter!(app -> occursin(r"^MATLAB_R[0-9]+[ab]\.app$", app), dirs)
                    if !isempty(dirs)
                        matlab_root = joinpath(default_dir, maximum(dirs))
                    end
                end
            elseif Sys.iswindows()
                default_dir = Sys.WORD_SIZE == 32 ? "C:\\Program Files (x86)\\MATLAB" : "C:\\Program Files\\MATLAB"
                if isdir(default_dir)
                    dirs = readdir(default_dir)
                    filter!(dir -> occursin(r"^R[0-9]+[ab]$", dir), dirs)
                    if !isempty(dirs)
                        matlab_root = joinpath(default_dir, maximum(dirs))
                    end
                end
            elseif Sys.islinux()
                # /opt/hostedtoolcache/MATLAB/2024.2.999/x64


                default_dir = "/usr/local/MATLAB"
                if isdir(default_dir)
                    dirs = readdir(default_dir)
                    filter!(dir -> occursin(r"^R[0-9]+[ab]$", dir), dirs)
                    if !isempty(dirs)
                        matlab_root = joinpath(default_dir, maximum(dirs))
                    end
                end
            end
        end
    elseif get(ENV, "CI", "false") == "true"
        # CI environment, try to find MATLAB root folder
        candidates = find_matlab_root_ci_candidates()
        for candidate in candidates
            matlab_exe = Sys.which(joinpath(candidate, "bin", "matlab"))
            if !isnothing(matlab_exe)
                matlab_root = candidate
                break
            end
        end
    end
    !isnothing(matlab_root) && isdir(matlab_root) && @info("Detected MATLAB root folder at \"$matlab_root\"")
    return matlab_root
end


function find_matlab_root_ci_candidates(default_dir = "/opt/hostedtoolcache/MATLAB")
    if !isdir(default_dir)
        return nothing
    end
    dirs = sort(filter(isdir, readdir(default_dir)), rev=true) # sort in reverse order
    return map(d -> joinpath(default_dir, d), dirs) # return list of candidate MATLAB roots
end

function find_matlab_libpath(matlab_root)
    # get path to MATLAB libraries
    matlab_libdir = if Sys.islinux()
        Sys.WORD_SIZE == 32 ? "glnx86" : "glnxa64"
    elseif Sys.isapple()
        archchar = Sys.ARCH == :aarch64 ? "a" : "i"
        Sys.WORD_SIZE == 32 ? "maci" : "mac" * archchar * "64"
    elseif Sys.iswindows()
        Sys.WORD_SIZE == 32 ? "win32" : "win64"
    end
    matlab_libpath = joinpath(matlab_root, "bin", matlab_libdir)
    isdir(matlab_libpath) && @info("Detected MATLAB library path at \"$matlab_libpath\"")
    return matlab_libpath
end

function find_matlab_cmd(matlab_root)
    if Sys.iswindows()
        matlab_cmd = joinpath(matlab_root, "bin", (Sys.WORD_SIZE == 32 ? "win32" : "win64"), "matlab.exe")
        isfile(matlab_cmd) && @info("Detected MATLAB executable at \"$matlab_cmd\"")
    else
        matlab_exe = joinpath(matlab_root, "bin", "matlab")
        isfile(matlab_exe) && @info("Detected MATLAB executable at \"$matlab_exe\"")
        matlab_cmd = "exec $(Base.shell_escape(matlab_exe))"
    end
    return matlab_cmd
end

matlab_root = find_matlab_root()

if !isnothing(matlab_root)
    matlab_libpath = find_matlab_libpath(matlab_root)
    matlab_cmd = find_matlab_cmd(matlab_root)
    libmx_size = filesize(Libdl.dlpath(joinpath(matlab_libpath, "libmx")))
    open(depsfile, "w") do io
        println(io,
            """
            # This file is automatically generated, do not edit.

            function check_deps()
                if libmx_size != filesize(Libdl.dlpath(joinpath(matlab_libpath, "libmx")))
                    error("MATLAB library has changed, re-run Pkg.build(\\\"MATLAB\\\")")
                end
            end
            """
        )
        println(io, "const matlab_libpath = \"$(escape_string(matlab_libpath))\"")
        println(io, "const matlab_cmd = \"$(escape_string(matlab_cmd))\"")
        println(io, "const libmx_size = $libmx_size")
    end
elseif get(ENV, "JULIA_REGISTRYCI_AUTOMERGE", nothing) == "true" || get(ENV, "CI", nothing) == "true"
    # We need to be able to install and load this package without error for
    # Julia's registry AutoMerge to work, so we just use dummy values.
    # Similarly we want to also be able to install and load this package for CI.
    matlab_libpath = ""
    matlab_cmd = ""
    libmx_size = 0

    open(depsfile, "w") do io
        println(io,
            """
            # This file is automatically generated, do not edit.

            check_deps() = nothing
            """
        )
        println(io, "const matlab_libpath = \"$(escape_string(matlab_libpath))\"")
        println(io, "const matlab_cmd = \"$(escape_string(matlab_cmd))\"")
        println(io, "const libmx_size = $libmx_size")
    end
else
    error("MATLAB cannot be found. Set the \"MATLAB_ROOT\" environment variable to the MATLAB root directory and re-run Pkg.build(\"MATLAB\").")
end
