###################################################
#  Setup googletest to include all test cases
#  written in .cpp files under the test/ directory
#
#  Uses: SETUP_GOOGLETEST()
###################################################
macro(SETUP_GOOGLETEST)
  if(DEFINED BII_LIB_SRC)
    FILE(GLOB_RECURSE test_files test/*.cpp) 
    if(test_files)
      LIST(REMOVE_ITEM BII_LIB_SRC ${test_files})
      SET(BII_test_main_SRC ${BII_test_main_SRC} ${test_files})
    endif(test_files)
  endif(DEFINED BII_LIB_SRC)
endmacro(SETUP_GOOGLETEST)


###################################################
#  Activate C++14
#
#  Uses: ACTIVATE_CPP14()
###################################################
macro(ACTIVATE_CPP14)
  IF(APPLE)
    TARGET_COMPILE_OPTIONS(${BII_BLOCK_TARGET} INTERFACE "-std=c++14 -stdlib=libc++")
  ELSEIF (WIN32 OR UNIX)
    IF (CMAKE_COMPILER_IS_GNUCXX)
      EXECUTE_PROCESS(COMMAND ${CMAKE_CXX_COMPILER} -dumpversion OUTPUT_VARIABLE GCC_VERSION)
      IF (GCC_VERSION VERSION_LESS 4.8)
        MESSAGE(FATAL_ERROR "Found GCC ${GCC_VERSION}. Need at least GCC 4.8 for c++14 support")
      ELSEIF (GCC_VERSION VERSION_LESS 4.9)
        MESSAGE(WARNING "Found GCC ${GCC_VERSION}. Only very limited C++14 support available!")
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++1y")
      ELSE()
        MESSAGE(STATUS "Found GCC ${GCC_VERSION}")  
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
      ENDIF(GCC_VERSION VERSION_LESS 4.9)
    ELSEIF(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
      EXECUTE_PROCESS( COMMAND ${CMAKE_CXX_COMPILER} --version OUTPUT_VARIABLE clang_full_version_string )
      string(REGEX REPLACE ".*clang version ([0-9]+\\.[0-9]+).*" "\\1" CLANG_VERSION_STRING ${clang_full_version_string})
      IF(CLANG_VERSION_STRING VERSION_LESS 3.4)
        MESSAGE(FATAL_ERROR "Found clang ${CLANG_VERSION_STRING}. Need at least clang 3.4 for c++14 support")
      ELSEIF(CLANG_VERSION_STRING VERSION_LESS 3.5)
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++1y -stdlib=libc++")
      ELSE()
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -stdlib=libc++")
      ENDIF()
    ELSE()
      MESSAGE(WARNING "Unknown compiler (not gcc or clang). Trying -std=c++14 parameter")
      TARGET_COMPILE_OPTIONS(${BII_BLOCK_TARGET} INTERFACE "-std=c++14")
    ENDIF(CMAKE_COMPILER_IS_GNUCXX)
  ENDIF(APPLE)
endmacro(ACTIVATE_CPP14)


##################################################
# Specify that a specific minimal version of gcc is required
#
# Uses:
#  REQUIRE_GCC_VERSION(4.9)
##################################################
function(REQUIRE_GCC_VERSION)
  IF (CMAKE_COMPILER_IS_GNUCXX)
    EXECUTE_PROCESS(COMMAND ${CMAKE_CXX_COMPILER} -dumpversion OUTPUT_VARIABLE GCC_VERSION)
    IF (GCC_VERSION VERSION_LESS ${ARGN})
      MESSAGE(FATAL_ERROR "Needs at least gcc version ${ARGN}, found gcc ${GCC_VERSION}")
    ENDIF()
  ENDIF()
endfunction(NEED_GCC_VERSION)


INCLUDE(biicode/boost/setup)

##################################################
# Add boost to the project
#
# Uses:
#  ADD_BOOST() # if you're only using header-only boost libs
#  ADD_BOOST(system filesystem) # list all libraries to link against in the dependencies
##################################################
function(ADD_BOOST)
  # Load boost libraries
  set(Boost_USE_STATIC_LIBS ON)
  bii_find_boost(COMPONENTS ${ARGN} REQUIRED)
  target_include_directories(${BII_BLOCK_TARGET} INTERFACE ${Boost_INCLUDE_DIRS})
  target_link_libraries(${BII_BLOCK_TARGET} INTERFACE ${Boost_LIBRARIES})
endfunction()
