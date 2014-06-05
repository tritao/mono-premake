include("helpers.lua")

GenerateBuildVersion("buildver-sgen.h")

solution "Mono"

	configurations { "Debug", "Release" }
	platforms { "x32", "x64" }
	
	flags { common_flags }
	framework "4.5"
	
	location (builddir)
	objdir (builddir .. "/obj/")
	targetdir (libdir)
	libdirs { libdir }

	group "Compiler"
		include("mcs.lua")

	group "Class Libraries"
		include("classlibs.lua")

	group "Profilers"
		include("profilers.lua")

	group "Runtime"
		include("eglib.lua")
		include("mono.lua")

	group "Tools"
		include("tools.lua")
