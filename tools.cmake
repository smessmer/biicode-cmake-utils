###################################################
#  Setup googletest to include all test cases
#  written in .cpp files under the test/ directory
#
#  Uses: SETUP_GOOGLETEST()
###################################################
macro(SETUP_GOOGLETEST)
  if(DEFINED BII_LIB_SRC)
    FILE(GLOB test_files test/*.cpp) 
    LIST(REMOVE_ITEM BII_LIB_SRC ${test_files})
    SET(BII_test_main_SRC ${BII_test_main_SRC} ${test_files})
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
    TARGET_COMPILE_OPTIONS(${BII_BLOCK_TARGET} INTERFACE "-std=c++14")
  ENDIF(APPLE)
endmacro(ACTIVATE_CPP14)

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
