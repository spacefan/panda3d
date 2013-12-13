# PRC Config settings
set(PRC_DEFAULT_DIR_ABSOLUTE "" CACHE STRING
  "Specify the PRC_DEFAULT_DIR as an absolute path.")
if(NOT PRC_DEFAULT_DIR_ABSOLUTE)
	set(PRC_DEFAULT_DIR "etc" CACHE STRING
	  "Panda uses prc files for runtime configuration. Panda will search the
default .prc directory if the PRC_PATH and PRC_DIR environment variables
are not defined.")
else()
	set(PRC_DEFAULT_DIR "" CACHE STRING
    "Panda uses prc files for runtime configuration. Panda will search the
default .prc directory if the PRC_PATH and PRC_DIR environment variables
are not defined.")
endif()
set(PRC_DCONFIG_TRUST_LEVEL 0 CACHE STRING
  "The trust level value for any legacy (DConfig) variables.")
set(PRC_INC_TRUST_LEVEL 0 CACHE STRING
  "The amount by which we globally increment the trust level.")
if(PRC_DEFAULT_DIR AND PRC_DEFAULT_DIR_ABSOLUTE)
	message("Using PRC_DEFAULT_DIR_ABSOLUTE instead of PRC_DEFAULT_DIR.")
endif()

# PRC special values for config headers
if(PRC_DEFAULT_DIR_ABSOLUTE)
	set(DEFAULT_PRC_DIR ${PRC_ABSOLUTE_DIR})
else()
	set(DEFAULT_PRC_DIR "${CMAKE_INSTALL_PREFIX}/panda/${PRC_DEFAULT_DIR}")
endif()

### Configure interrogate ###
message(STATUS "") # simple line break
if(HAVE_PYTHON AND HAVE_OPENSSL)
  option(USE_INTERROGATE "If on, Panda3D will generate python interfaces" ON)
  if(USE_INTERROGATE)
    set(HAVE_INTERROGATE TRUE)
  endif()
else()
  unset(USE_INTERROGATE CACHE)
endif()
if(HAVE_INTERROGATE)
  message(STATUS "Compilation will generate Python interfaces.")
else()
  message(STATUS "Configuring Panda without Python interfaces.")
endif()


### Configure threading support ###
find_package(Threads)
if(THREADS_FOUND)
  # Add basic use flag for threading
  option(BUILD_THREADS "If on, compile Panda3D with threading support." ON)
  if(BUILD_THREADS)
    set(HAVE_THREADS TRUE)
  else()
    unset(BUILD_SIMPLE_THREADS CACHE)
    unset(BUILD_OS_SIMPLE_THREADS CACHE)
  endif()
else()
  unset(BUILD_THREADS CACHE)
endif()

# Configure debug threads
# Add advanced threading configuration
if(HAVE_THREADS)
  if(CMAKE_BUILD_TYPE MATCHES "Debug")
    option(BUILD_DEBUG_THREADS "If on, enables debugging of thread and sync operations (i.e. mutexes, deadlocks)" ON)
  else()
    option(BUILD_DEBUG_THREADS "If on, enables debugging of thread and sync operations (i.e. mutexes, deadlocks)" OFF)
  endif()
  if(BUILD_DEBUG_THREADS)
    set(DEBUG_THREADS TRUE)
  endif()

  set(HAVE_POSIX_THREADS ${CMAKE_USE_PTHREADS_INIT})
  if(HAVE_POSIX_THREADS)
    set(CMAKE_CXX_FLAGS "-pthread")
    set(CMAKE_CXX_FLAGS_DEBUG "-pthread")
    set(CMAKE_CXX_FLAGS_RELEASE "-pthread")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-pthread")
    set(CMAKE_CXX_FLAGS_MINSIZEREL "-pthread")
  endif()

  option(BUILD_SIMPLE_THREADS "If on, compile with simulated threads." OFF)
  if(BUILD_SIMPLE_THREADS)
    message(STATUS "Compilation will include simulated threading support.")
    option(BUILD_OS_SIMPLE_THREADS "If on, OS threading constructs will be used to perform context switches." ON)

    set(SIMPLE_THREADS TRUE)
    if(BUILD_OS_SIMPLE_THREADS)
      set(OS_SIMPLE_THREADS TRUE)
    endif()
  else()
    unset(BUILD_OS_SIMPLE_THREADS CACHE)

    option(BUILD_PIPELINING "If on, compile with pipelined rendering." ON)
    if(BUILD_PIPELINING)
      message(STATUS "Compilation will include full, pipelined threading support.")
    else()
      message(STATUS "Compilation will include nonpipelined threading support.")
    endif()
  endif()
else()
  message(STATUS "Configuring Panda without threading support.")
endif()


### Configure pipelining ###
if(NOT DEFINED BUILD_PIPELINING)
  option(BUILD_PIPELINING "If on, compile with pipelined rendering." ON)
endif()
if(BUILD_PIPELINING)
  set(DO_PIPELINING TRUE)
endif()

### Configure OS X options ###
if(APPLE)
  option(BUILD_UNIVERSIAL_BINARIES "If on, compiling will create universal OS X binaries." ON)
  if(BUILD_UNIVERSAL_BINARIES)
    message(STATUS "Compilation will create universal binaries.")
    set(UNIVERSAL_BINARIES TRUE)
  else()
    message(STATUS "Compilation will not create universal binaries.")
  endif()
endif()

message(STATUS "")
message(STATUS "See dtool_config.h for more details about the specified configuration.\n")


### Check for system support of various values ###
# Do we have all these header files?
include(CheckIncludeFileCXX)
check_include_file_cxx(io.h PHAVE_IO_H)
check_include_file_cxx(iostream PHAVE_IOSTREAM)
check_include_file_cxx(malloc.h PHAVE_MALLOC_H)
check_include_file_cxx(sys/malloc.h PHAVE_SYS_MALLOC_H)
check_include_file_cxx(alloca.h PHAVE_ALLOCA_H)
check_include_file_cxx(locale.h PHAVE_LOCALE_H)
check_include_file_cxx(string.h PHAVE_STRING_H)
check_include_file_cxx(stdlib.h PHAVE_STDLIB_H)
check_include_file_cxx(limits.h PHAVE_LIMITS_H)
check_include_file_cxx(minmax.h PHAVE_MINMAX_H)
check_include_file_cxx(sstream PHAVE_SSTREAM)
check_include_file_cxx(new PHAVE_NEW)
check_include_file_cxx(sys/types.h PHAVE_SYS_TYPES_H)
check_include_file_cxx(sys/time.h PHAVE_SYS_TIME_H)
check_include_file_cxx(unistd.h PHAVE_UNISTD_H)
check_include_file_cxx(utime.h PHAVE_UTIME_H)
check_include_file_cxx(glob.h PHAVE_GLOB_H)
check_include_file_cxx(dirent.h PHAVE_DIRENT_H)
check_include_file_cxx(drfftw.h PHAVE_DRFFTW_H)
check_include_file_cxx(sys/soundcard.h PHAVE_SYS_SOUNDCARD_H)
check_include_file_cxx(ucontext.h PHAVE_UCONTEXT_H)
check_include_file_cxx(linux/input.h PHAVE_LINUX_INPUT_H)
check_include_file_cxx(stdint.h PHAVE_STDINT_H)
check_include_file_cxx(typeinfo HAVE_RTTI)
check_include_file_cxx(getopt.h PHAVE_GETOPT_H)

# Do we have these sized type definitions
include(CheckTypeSize)
check_type_size(wchar_t WCHAR_T)

# Does the compiler accept these declarations
include(CheckCXXSourceCompiles)
check_cxx_source_compiles(
  "#include <string>
   std::wstring str;
   int main(int argc, char *argv[]) { return 0; }"
  HAVE_WSTRING)

# Do we have these standard functions
include(CheckFunctionExists)
check_function_exists(getopt HAVE_GETOPT)
check_function_exists(getopt_long_only HAVE_GETOPT_LONG_ONLY)

# Are we on a big endian system?
include(TestBigEndian)
test_big_endian(WORDS_BIGENDIAN)

# Do we support std namespaces?
include(TestForSTDNamespace)
set(HAVE_NAMESPACE CMAKE_STD_NAMESPACE)

# Can we read the file /proc/self/[*] to determine our
# environment variables at static init time?
if(EXISTS "/proc/self/exe")
  set(HAVE_PROC_SELF_EXE TRUE)
endif()
if(EXISTS "/proc/self/maps")
  set(HAVE_PROC_SELF_MAPS TRUE)
endif()
if(EXISTS "/proc/self/environ")
  set(HAVE_PROC_SELF_ENVIRON TRUE)
endif()
if(EXISTS "/proc/self/cmdline")
  set(HAVE_PROC_SELF_CMDLINE TRUE)
endif()
if(EXISTS "/proc/curproc/file")
  set(HAVE_PROC_CURPROC_FILE TRUE)
endif()
if(EXISTS "/proc/curproc/map")
  set(HAVE_PROC_CURPROC_MAP TRUE)
endif()
if(EXISTS "/proc/curproc/cmdline")
  set(HAVE_PROC_CURPROC_CMDLINE TRUE)
endif()

# TODO: Actually check for these, instead of assuming
set(HAVE_LOCKF TRUE)
set(HAVE_TYPENAME TRUE)
set(SIMPLE_STRUCT_POINTERS TRUE)
set(HAVE_STREAMSIZE TRUE)
set(HAVE_IOS_TYPEDEFS TRUE)

if(WIN32)
  set(DEFAULT_PATHSEP ";")
else()
  set(DEFAULT_PATHSEP ":")
endif()

configure_file(dtool/dtool_config.h.cmake ${CMAKE_BINARY_DIR}/include/dtool_config.h)