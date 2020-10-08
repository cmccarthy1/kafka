cmake_minimum_required(VERSION 2.8)
project(libkfk C)

set (CMAKE_BUILD_TYPE Release)
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -DKXVER=3")
set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -DKXVER=3")

set(MY_LIBRARY_NAME libkfk)
file(GLOB SRC_FILES src/kfk.c)
set_source_files_properties(${SRC_FILES} PROPERTIES LANGUAGE C)

message(STATUS "Generator : ${CMAKE_GENERATOR}")
message(STATUS "Build Tool : ${CMAKE_BUILD_TOOL}")
message(STATUS "Custom librdkafka API location : $ENV{BUILD_HOME}")

include_directories (
    $ENV{BUILD_HOME}/include # Absolute BUILD_HOME
    ${CMAKE_BINARY_DIR}/$ENV{BUILD_HOME}/include # Relative BUILD_HOME
    ${CMAKE_BINARY_DIR} # For 'k.h', downloaded below
)

find_library(LIBRDKAFKA
    NAMES librdkafka rdkafka
    HINTS # Don't quote these in case BUILD_HOME is already quoted
    $ENV{BUILD_HOME}/lib # Absolute
    ${CMAKE_BINARY_DIR}/$ENV{BUILD_HOME}/lib # Relative
)

file(DOWNLOAD "https://github.com/KxSystems/kdb/raw/master/c/c/k.h" "${CMAKE_BINARY_DIR}/k.h" )

if (CMAKE_GENERATOR MATCHES "Visual Studio")
    set(INSTALL_SCRIPT "install.bat")
    file(DOWNLOAD "https://github.com/KxSystems/kdb/raw/master/w64/q.lib" "${CMAKE_BINARY_DIR}/q.lib" )
    set(LINK_LIBS "${CMAKE_BINARY_DIR}/q.lib") 
else()
    set(INSTALL_SCRIPT "install.sh")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-strict-aliasing")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-strict-aliasing")
endif()
    
add_library (${MY_LIBRARY_NAME} SHARED ${SRC_FILES})

target_link_libraries(${MY_LIBRARY_NAME} ${LIBRDKAFKA} ${LINK_LIBS})
set_target_properties(${MY_LIBRARY_NAME} PROPERTIES PREFIX "")

if(APPLE)
    set(OSFLAG m)
    set_target_properties(${MY_LIBRARY_NAME} PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
    set_target_properties(${MY_LIBRARY_NAME} PROPERTIES SUFFIX .so)
elseif(WIN32)
    set(OSFLAG w)
else()
    set(OSFLAG l)
endif()

set(BITNESS 32)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(BITNESS 64)
endif()

if(DEFINED ENV{QHOME})
    file(TO_CMAKE_PATH "$ENV{QHOME}" QHOME_PATH)
    install(TARGETS ${MY_LIBRARY_NAME} DESTINATION "${QHOME_PATH}/${OSFLAG}${BITNESS}/")
    install(DIRECTORY "q/" DESTINATION "${QHOME_PATH}" FILES_MATCHING PATTERN "*.q")
endif()

install(FILES README.md LICENSE ${INSTALL_SCRIPT} DESTINATION ${PROJECT_BINARY_DIR}/kdbkafka/)
install(DIRECTORY examples DESTINATION ${PROJECT_BINARY_DIR}/kdbkafka)
install(DIRECTORY q DESTINATION ${PROJECT_BINARY_DIR}/kdbkafka)
install(TARGETS ${MY_LIBRARY_NAME} DESTINATION ${PROJECT_BINARY_DIR}/kdbkafka/lib OPTIONAL)
