-- This module checks for the all the project dependencies.

action = _ACTION or ""

builddir = path.getabsolute("./" .. action)
libdir = path.join(builddir, "lib")
gendir = path.join(builddir, "gen")
os.mkdir(gendir)

common_flags = { "Unicode", "Symbols" }
msvc_buildflags = { } 
gcc_buildflags = {  }

msvc_cpp_defines = { }

MONO_ROOT = "../../"

function SetupNativeProject()
  --location (path.join(builddir, "projects"))

  local c = configuration "Debug"
    
  configuration "Release"
    defines { "NDEBUG" }
    
  -- Compiler-specific options
  
  configuration "vs*"
    buildoptions { msvc_buildflags }
    defines { msvc_cpp_defines }
    
  configuration "gcc"
    buildoptions { gcc_buildflags }
  
  -- OS-specific options
  
  configuration "Windows"
    defines { "WIN32", "_WINDOWS" }
  
  configuration(c)
end

function SetupManagedProject()
  language "C#"
  location (path.join(builddir, "projects"))
end

function SetupWindowsDefines()
    defines
    {
      "WIN32_THREADS",
      "_WIN32_WINNT=0x0502", 
      "UNICODE",
      "_UNICODE",
      "FD_SETSIZE=1024"
    }
end

function IncludeDir(dir)
  local deps = os.matchdirs(dir .. "/*")
  
  for i,dep in ipairs(deps) do
    local fp = path.join(dep, "premake4.lua")
    fp = path.join(os.getcwd(), fp)
    
    if os.isfile(fp) then
      print(string.format(" including %s", dep))
      include(dep)
    end
  end
end

function WriteToFile(path, content)
  file = io.open(path, "w")
  file:write(content)
  file:close()
end

function GenerateBuildVersion(file)
  print("Generating build version file: " .. file)
  local contents = "const char *build_date = \"\";"
  WriteToFile(gendir .. '/' .. file, contents)
end

local vstudio = premake.vstudio
local vc2010 = vstudio.vc2010

local originalPlatformToolset = vc2010.platformToolset

local useClangCl = false

function vc2010.platformToolset(cfg)
  if useClangCl then
    _p(2,'<PlatformToolset>LLVM-vs2012</PlatformToolset>')
  else
    originalPlatformToolset(cfg)
  end
end

function SetupWindowsWarnings()
  buildoptions
  {
    "/wd4018", -- signed/unsigned mismatch
    "/wd4244", -- conversion from 'x' to 'y', possible loss of data
    "/wd4133", -- incompatible types - from 'x *' to 'y *'
    "/wd4715", -- not all control paths return a value
    "/wd4047", -- 'x' differs in levels of indirection from 'y'
  }

  -- clang-cl specific warnings
  if useClangCl then
    buildoptions
    {      
      "-Wno-implicit-int",
      "-Wno-implicit-function-declaration",
      "-Wno-return-type",
      "-Wno-unused-variable",
      "-Wno-deprecated-declarations",
      "-Wno-parentheses",
      "-Wno-incompatible-pointer-types",
      "-Wno-missing-braces",
      "-Wno-unused-function",
    }
  end
end