JAY_ROOT = MCS_ROOT .. 'jay/'

project "jay"

  SetupNativeProject()
  SetupWindowsWarnings()
  
  removedefines { "DEBUG" }

  kind "ConsoleApp"
  language "C"

  defines { "SKEL_DIRECTORY=\".\""}
  files { JAY_ROOT .. "*.c" }

  configuration "vs*"

    buildoptions
    {
        "/wd4033", "/wd4013", "/wd4996", "/wd4267",  "/wd4273",
        "/wd4113", "/wd4244", "/wd4715", "/wd4716"
    }
