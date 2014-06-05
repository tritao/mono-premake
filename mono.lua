MONO_RUNTIME_ROOT = MONO_ROOT .. "mono/"

function SetupSGen()
	local c = configuration()

	defines
	{
		"HAVE_SGEN_GC",
		"HAVE_MOVING_COLLECTOR",
		"HAVE_WRITE_BARRIERS",
		"MONO_DLL_EXPORT"
	}

	files
	{
		MONO_RUNTIME_ROOT .. "metadata/sgen-*.*"
	}

	configuration "windows"
		files { MONO_RUNTIME_ROOT .. "metadata/sgen-os-win*.c" }

	configuration "not windows"
		files { MONO_RUNTIME_ROOT .. "metadata/sgen-os-posix.c" }

	configuration "osx"
		files { MONO_RUNTIME_ROOT .. "metadata/sgen-os-mach.c" }

	configuration(c)
end

function SetupConfigDefines()
	defines
	{
		"HAVE_DECL_INTERLOCKEDCOMPAREEXCHANGE64=1",
		"HAVE_DECL_INTERLOCKEDEXCHANGE64=1",
		"HAVE_DECL_INTERLOCKEDINCREMENT64=1",
		"HAVE_DECL_INTERLOCKEDDECREMENT64=1",
		"HAVE_DECL_INTERLOCKEDADD=1",
		"HAVE_DECL_INTERLOCKEDADD64=1",
		"HAVE_DECL_INTERLOCKEDCOMPAREEXCHANGE64=1",
		"HAVE_DECL___READFSDWORD=1",
	}
end

function GenerateConfig()
	if not os.is("windows") then
		return
	end

	print('Generating Windows config.h')
	os.copyfile(MONO_ROOT .. "winconfig.h", gendir .. "/config.h")
end

function GenerateVersion()
	print('Generating version.h')

	local contents
	if os.isdir(MONO_ROOT .. ".git") then
		local branches = os.outputof("set LANG=C && git branch")
		local branch = string.gmatch(branches, "^\* (%w+)")()
		local version = os.outputof("set LANG=C && git log --no-color --first-parent -n1 --pretty=format:%h")
		contents = string.format("#define FULL_VERSION \"%s/%s\"", branch, version)
	else
		contents = "#define FULL_VERSION \"tarball\""
	end

	file = io.open(path.getabsolute(gendir .. "/version.h"), "w+")
	file:write(contents)
	file:close()
end

function SetupMonoIncludes()
	includedirs
	{
		gendir,
		MONO_RUNTIME_ROOT,
		MONO_RUNTIME_ROOT .. "..",
		MONO_RUNTIME_ROOT .. "../eglib/src",
		MONO_RUNTIME_ROOT .. "utils/",
	}
end

GenerateConfig()
GenerateVersion()

project "mono"

	SetupNativeProject()
	
	kind "ConsoleApp"
	language "C"

	files
	{
		MONO_RUNTIME_ROOT .. "mini/main.c",
	}

	includedirs
	{
		gendir,
		MONO_RUNTIME_ROOT .. "../",
		MONO_RUNTIME_ROOT .. "../eglib/src/"
	}	
	
	links
	{
		"eglib",
		"libmono",
		"libmonoruntime",
		"libmonoutils"
	}

	configuration "vs*"
		defines { "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_DEPRECATE" }
		SetupConfigDefines()

function GenerateMachineDescription(arch)
	local prj = premake.api.scope.project.location
	local abs = path.getabsolute(MONO_RUNTIME_ROOT .. 'mini/cpu-' .. arch .. '.md')
	local input = path.getrelative(prj, abs)	
	local out = gendir .. '/cpu-' .. arch .. '.h'
	local desc = arch .. '_desc'

	prebuildcommands
	{
		'"%{cfg.targetdir}/genmdesc" ' .. out .. ' ' .. desc .. ' ' .. input
	}
end

function SetupMonoLinks()
	local c = configuration()

	links
	{
		"eglib",
		"libmonoruntime",
		"libmonoutils"
	}

	configuration "windows"

		links
		{
			"Mswsock",
			"ws2_32",
			"psapi",
			"version",
			"winmm",
		}

	configuration(c)
end

project "libmono"

	SetupNativeProject()

	kind "SharedLib"
	language "C"

	defines
	{
		"__default_codegen__",
		"HAVE_CONFIG_H",
		"MONO_DLL_EXPORT"
	}
	
	SetupMonoIncludes()
	SetupMonoLinks()

	files
	{
		MONO_RUNTIME_ROOT .. "mini/*.c",
		MONO_RUNTIME_ROOT .. "mini/*.h",
	}
	
	excludes
	{
		-- Archicture-specific files
		MONO_RUNTIME_ROOT .. "mini/*-alpha.*",
		MONO_RUNTIME_ROOT .. "mini/*-amd64.*",
		MONO_RUNTIME_ROOT .. "mini/*-arm.*",
		MONO_RUNTIME_ROOT .. "mini/*-arm64.*",
		MONO_RUNTIME_ROOT .. "mini/*-hppa.*",
		MONO_RUNTIME_ROOT .. "mini/*-ia64.*",
		MONO_RUNTIME_ROOT .. "mini/*-llvm.*",
		MONO_RUNTIME_ROOT .. "mini/*-mips.*",
		MONO_RUNTIME_ROOT .. "mini/*-ppc.*",		
		MONO_RUNTIME_ROOT .. "mini/*-s390*.*",
		MONO_RUNTIME_ROOT .. "mini/*-sparc.*",
		MONO_RUNTIME_ROOT .. "mini/*-x86.*",

		-- Platform-specific files
		MONO_RUNTIME_ROOT .. "mini/*-windows.*",
		MONO_RUNTIME_ROOT .. "mini/*-darwin.*",
		MONO_RUNTIME_ROOT .. "mini/*-posix.*",

		-- Tools
		MONO_RUNTIME_ROOT .. "mini/fsacheck.c",
		MONO_RUNTIME_ROOT .. "mini/genmdesc.c",
		MONO_RUNTIME_ROOT .. "mini/main.c",		
	}

	dependson { "genmdesc" }
	
	configuration "x32"
		GenerateMachineDescription('x86')
		files
		{
			MONO_RUNTIME_ROOT .. "mini/*-x86.c",
		}

	configuration "x64"
		GenerateMachineDescription('amd64')
		files
		{
			MONO_RUNTIME_ROOT .. "mini/*-amd64.c",
		}	

	configuration "windows"
		SetupWindowsDefines()
		SetupWindowsWarnings()
		files
		{
			MONO_RUNTIME_ROOT .. "mini/*-windows.c"
		}

	configuration "not windows"
		files
		{
			MONO_RUNTIME_ROOT .. "mini/*-posix.c"
		}

	configuration "macosx"
		files
		{
			MONO_RUNTIME_ROOT .. "mini/*-darwin.c"
		}

	configuration "vs*"
		defines { "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_DEPRECATE" }
		SetupConfigDefines()
		buildoptions
		{
			"/wd4018", -- signed/unsigned mismatch
			"/wd4244", -- conversion from 'x' to 'y', possible loss of data
			"/wd4133", -- incompatible types - from 'x *' to 'y *'
			"/wd4715", -- not all control paths return a value
			"/wd4047", -- 'x' differs in levels of indirection from 'y'
		}
		linkoptions
		{
			"/ignore:4049", -- locally defined symbol imported
			"/ignore:4217", -- locally defined symbol imported in function
		}		

project "libmonoruntime"

	SetupNativeProject()
	
	kind "StaticLib"
	language "C"
	
	defines
	{
		"HAVE_CONFIG_H",
	}

	SetupMonoIncludes()
	
	files
	{
		MONO_RUNTIME_ROOT .. "metadata/*.c",
		MONO_RUNTIME_ROOT .. "metadata/*.h",
	}

	excludes
	{	
		-- GC-specific files
		MONO_RUNTIME_ROOT .. "metadata/boehm-gc.c",
		MONO_RUNTIME_ROOT .. "metadata/null-gc.c",
		MONO_RUNTIME_ROOT .. "metadata/sgen-*.*",
		MONO_RUNTIME_ROOT .. "metadata/sgen-os-*.*",
		
		-- Platform-specific files
		MONO_RUNTIME_ROOT .. "metadata/console-unix.c",
		MONO_RUNTIME_ROOT .. "metadata/console-win32.c",
		MONO_RUNTIME_ROOT .. "metadata/coree.c",

		-- Tools
		MONO_RUNTIME_ROOT .. "metadata/monodiet.c",
		MONO_RUNTIME_ROOT .. "metadata/monosn.c",
		MONO_RUNTIME_ROOT .. "metadata/pedump.c",
		MONO_RUNTIME_ROOT .. "metadata/tpool-*.c",
		MONO_RUNTIME_ROOT .. "metadata/test-*.c",
	}

	SetupSGen()

	configuration "windows"
		SetupWindowsDefines()

		files
		{
			MONO_RUNTIME_ROOT .. "metadata/coree.c",
		}

	configuration "linux"
		files
		{
			MONO_RUNTIME_ROOT .. "metadata/tpool-epoll.c"
		}
		
	configuration "macosx or freebsd"
		files
		{
			MONO_RUNTIME_ROOT .. "metadata/tpool-kqueue.c"
		}

	configuration "vs*"
		defines { "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_DEPRECATE" }
		SetupConfigDefines()
		SetupWindowsWarnings()

project "libmonoutils"

	SetupNativeProject()
	
	kind "StaticLib"
	language "C"
	
	defines
	{
		"HAVE_CONFIG_H",
	}

	SetupMonoIncludes()
	
	files
	{
		MONO_RUNTIME_ROOT .. "utils/*.c",
		MONO_RUNTIME_ROOT .. "utils/*.h",
	}

	excludes
	{	
		-- Platform-specific files
		MONO_RUNTIME_ROOT .. "utils/atomic.c",
		MONO_RUNTIME_ROOT .. "utils/mono-hwcap-*.*",
		MONO_RUNTIME_ROOT .. "utils/mono-threads-*.c",

		-- Tools
		MONO_RUNTIME_ROOT .. "utils/mono-embed.c",
	}

	configuration { "arm" }
		files { MONO_RUNTIME_ROOT .. "utils/mono-hwcap-arm.*" }

	configuration "x32 or x64"
		files { MONO_RUNTIME_ROOT .. "utils/mono-hwcap-x86.*" }

	configuration "windows"
		SetupWindowsDefines()
		files
		{
			MONO_RUNTIME_ROOT .. "metadata/coree.c",
			MONO_RUNTIME_ROOT .. "utils/mono-threads-windows.c",
		}
		links
		{
			"Mswsock",
			"ws2_32",
			"psapi",
			"version",
			"winmm",
			"eglib",
		}

	configuration "not windows"
		files
		{
			MONO_RUNTIME_ROOT .. "utils/mono-threads-posix.c",
		}

	configuration "macosx"
		files
		{
			MONO_RUNTIME_ROOT .. "utils/mono-threads-mach.c",
		}

	configuration "vs*"
		defines { "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_DEPRECATE" }
		SetupConfigDefines()
		SetupWindowsWarnings()
		buildoptions { "/wd4273", "/wd4197" }

