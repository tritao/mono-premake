include("jay.lua")

project "genmdesc"

	SetupNativeProject()
	removedefines { "DEBUG" }

	kind "ConsoleApp"
	language "C"

	files
	{
		MONO_RUNTIME_ROOT .. "mini/genmdesc.c",
		MONO_RUNTIME_ROOT .. "mini/helpers.c",
		MONO_RUNTIME_ROOT .. "utils/monobitset.c",
		MONO_RUNTIME_ROOT .. "metadata/opcodes.c"
	}

	SetupMonoIncludes()

	links
	{
		"eglib",
	}

	configuration "vs*"
		defines { "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_DEPRECATE" }
		SetupConfigDefines()
		SetupWindowsWarnings()
		buildoptions { "/wd4273", "/wd4197" }
		linkoptions
		{
			"/ignore:4049", -- locally defined symbol imported
			"/ignore:4217", -- locally defined symbol imported in function
		}		

project "monodiet"

	SetupNativeProject()
	kind "ConsoleApp"
	language "C"

	files
	{
		MONO_RUNTIME_ROOT .. "metadata/monodiet.c",
		MONO_RUNTIME_ROOT .. "metadata/opcodes.c"
	}

	SetupMonoIncludes()
	SetupMonoLinks()
	defines { "MONO_STATIC_BUILD" }

	configuration "vs*"
		defines { "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_DEPRECATE" }
		SetupConfigDefines()
		buildoptions
		{
			"/wd4217", -- locally defined symbol imported in function
			"/wd4273", -- inconsistent dll linkage
		}
		linkoptions
		{
			"/ignore:4049", -- locally defined symbol imported
			"/ignore:4217", -- locally defined symbol imported in function
		}
		
project "monodis"

	SetupNativeProject()
	kind "ConsoleApp"
	language "C"

	files
	{
		MONO_RUNTIME_ROOT .. "dis/*.c",
		MONO_RUNTIME_ROOT .. "dis/*.h",
		MONO_RUNTIME_ROOT .. "metadata/opcodes.c"
	}

	SetupMonoIncludes()
	SetupMonoLinks()
	defines { "MONO_STATIC_BUILD" }

	configuration "vs*"
		defines { "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_DEPRECATE" }
		SetupConfigDefines()
		buildoptions
		{
			"/wd4018", -- signed/unsigned mismatch
			"/wd4273", -- inconsistent dll linkage
		}
		linkoptions
		{
			"/ignore:4049", -- locally defined symbol imported
			"/ignore:4217", -- locally defined symbol imported in function
		}


project "monograph"

	SetupNativeProject()
	kind "ConsoleApp"
	language "C"

	files
	{
		MONO_RUNTIME_ROOT .. "monograph/*.c",
		MONO_RUNTIME_ROOT .. "monograph/*.h",
		MONO_RUNTIME_ROOT .. "metadata/opcodes.c"
	}

	SetupMonoIncludes()
	SetupMonoLinks()
	defines { "MONO_STATIC_BUILD" }

	configuration "vs*"
		defines { "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_DEPRECATE" }
		SetupConfigDefines()
		buildoptions
		{
			"/wd4018", -- signed/unsigned mismatch
			"/wd4273", -- inconsistent dll linkage
		}
		linkoptions
		{
			"/ignore:4049", -- locally defined symbol imported
			"/ignore:4217", -- locally defined symbol imported in function
		}


project "pedump"

	SetupNativeProject()
	kind "ConsoleApp"
	language "C"

	files
	{
		MONO_RUNTIME_ROOT .. "metadata/pedump.c"
	}

	SetupMonoIncludes()
	SetupMonoLinks()
	defines { "MONO_STATIC_BUILD" }

	configuration "vs*"
		defines { "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_DEPRECATE" }
		SetupConfigDefines()
		buildoptions
		{
			"/wd4018", -- signed/unsigned mismatch
			"/wd4273", -- inconsistent dll linkage
		}
		linkoptions
		{
			"/ignore:4049", -- locally defined symbol imported
			"/ignore:4217", -- locally defined symbol imported in function
		}
