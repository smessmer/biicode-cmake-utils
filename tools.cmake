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
    IF("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
      IF (CLANG_VERSION_STRING VERSION_GREATER 3.4)
        MESSAGE("Clang version: ${CLANG_VERSION_STRING}. Use -std=c++14")
        TARGET_COMPILE_OPTIONS(${BII_BLOCK_TARGET} INTERFACE "-std=c++14")
      ELSE()
        MESSAGE("Clang version: ${CLANG_VERSION_STRING}. Use -std=c++1y")
        TARGET_COMPILE_OPTIONS(${BII_BLOCK_TARGET} INTERFACE "-std=c++1y")
      ENDIF()
    ELSE()
      MESSAGE("Compiler is gcc. Use -std=c++14")
      TARGET_COMPILE_OPTIONS(${BII_BLOCK_TARGET} INTERFACE "-std=c++14")
    ENDIF()
  ENDIF(APPLE)
endmacro(ACTIVATE_CPP14)


###################################################
#  Link local boost libraries to your project
#
#  Uses: ADD_BOOST_LOCAL(boostlib1 boostlib2 ...)
###################################################
function(ADD_BOOST_LOCAL)
  # Load boost libraries
  set(Boost_USE_STATIC_LIBS ON)
  message(${ARGN})
  find_package(Boost REQUIRED COMPONENTS ${ARGN})

  # Add boost libraries
  TARGET_INCLUDE_DIRECTORIES(${BII_BLOCK_TARGET} INTERFACE ${Boost_INCLUDE_DIRS})
  IF (WIN32)
    TARGET_LINK_LIBRARIES(${BII_BLOCK_TARGET} INTERFACE "ws2_32" "wsock32" ${Boost_LIBRARIES})
  ELSEIF(APPLE OR UNIX)
    TARGET_LINK_LIBRARIES(${BII_BLOCK_TARGET} INTERFACE ${Boost_LIBRARIES})
  ENDIF(WIN32)
endfunction()
