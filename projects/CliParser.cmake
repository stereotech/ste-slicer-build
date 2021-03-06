find_package(Arcus 1.1 REQUIRED)

set(extra_cmake_args "")
set(cmake_generator "${CMAKE_GENERATOR}")
if(BUILD_OS_WINDOWS)
    set(extra_cmake_args -DArcus_DIR=${CMAKE_PREFIX_PATH}/lib-mingw/cmake/Arcus
                         -DCMAKE_LIBRARY_PATH=${CMAKE_PREFIX_PATH}/lib-mingw)
    set(cmake_generator "MinGW Makefiles")
elseif (BUILD_OS_OSX)
    if (CMAKE_OSX_DEPLOYMENT_TARGET)
        list(APPEND extra_cmake_args
            -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET})
    endif()
    if (CMAKE_OSX_SYSROOT)
        list(APPEND extra_cmake_args
            -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT})
    endif()
endif()

set(CLIPARSER_REPO_LINK "http://${CLIPARSER_DEPLOY_USERNAME}:${CLIPARSER_DEPLOY_TOKEN}@github.com/stereotech/Cli-Parser.git")
message(STATUS "Repo link: ${CLIPARSER_REPO_LINK}")


ExternalProject_Add(CliParser
    GIT_REPOSITORY ${CLIPARSER_REPO_LINK}
    GIT_TAG origin/${CLIPARSER_BRANCH_OR_TAG}
    GIT_SHALLOW 1
    STEP_TARGETS update
    CMAKE_GENERATOR "${cmake_generator}"
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
               -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX}
               -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
               -DCLI_PARSER_VERSION=${STESLICER_VERSION}
               -DENABLE_MORE_COMPILER_OPTIMIZATION_FLAGS=${CURAENGINE_ENABLE_MORE_COMPILER_OPTIMIZATION_FLAGS}
               -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON
               ${extra_cmake_args}
)

SetProjectDependencies(TARGET CliParser)

add_dependencies(update CliParser-update)
