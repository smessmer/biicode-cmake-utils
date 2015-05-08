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

INCLUDE(CheckCXXCompilerFlag)

###################################################
#  Activate C++14
#
#  Uses: ACTIVATE_CPP14()
###################################################
macro(ACTIVATE_CPP14)
  CHECK_CXX_COMPILER_FLAG("-std=c++14" COMPILER_HAS_CPP14_SUPPORT)
  IF (COMPILER_HAS_CPP14_SUPPORT)
    TARGET_COMPILE_OPTIONS(${BII_BLOCK_TARGET} INTERFACE -std=c++14)
  ELSE()
    CHECK_CXX_COMPILER_FLAG("-std=c++1y" COMPILER_HAS_CPP14_PARTIAL_SUPPORT)
    IF (COMPILER_HAS_CPP14_PARTIAL_SUPPORT)
      TARGET_COMPILE_OPTIONS(${BII_BLOCK_TARGET} INTERFACE -std=c++1y)
    ELSE()
      MESSAGE(FATAL_ERROR "Compiler doesn't support C++14")
    ENDIF()
  ENDIF()
  IF(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    TARGET_COMPILE_OPTIONS(${BII_BLOCK_TARGET} INTERFACE -stdlib=libc++)
  ENDIF()
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

#################################################
# Enable style compiler warnings
#################################################
macro(ENABLE_STYLE_WARNINGS)
#  TARGET_COMPILE_OPTIONS(${BII_BLOCK_TARGET} INTERFACE -Wall -Wextra -Weffc++)
  TARGET_COMPILE_OPTIONS(${BII_BLOCK_TARGET} INTERFACE -Wall -Wextra)
endmacro(ENABLE_STYLE_WARNINGS)

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
  target_include_directories(${BII_BLOCK_TARGET} SYSTEM INTERFACE ${Boost_INCLUDE_DIRS})
  target_link_libraries(${BII_BLOCK_TARGET} INTERFACE ${Boost_LIBRARIES})
endfunction()
