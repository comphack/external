# This file is part of COMP_hack.
#
# Copyright (C) 2010-2018 COMP_hack Team <compomega@tutanota.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

CMAKE_MINIMUM_REQUIRED(VERSION 3.2.3)

# Use folders to organize the projects and files.
SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)

# Only show Debug and Release configurations in Visual Studio.
IF(CMAKE_CUSTOM_CONFIGURATION_TYPES)
    SET(CMAKE_CONFIGURATION_TYPES "${CMAKE_CUSTOM_CONFIGURATION_TYPES}" CACHE STRING "" FORCE)
ELSEIF(CMAKE_CONFIGURATION_TYPES)
    SET(CMAKE_CONFIGURATION_TYPES "Debug;Release;RelWithDebInfo" CACHE STRING "" FORCE)
ENDIF()

PROJECT(external)

# Print the CMake version for debugging.
MESSAGE("-- CMake version: ${CMAKE_VERSION}")

# Our custom cmake modules.
SET(COMP_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# Include our custom cmake modules.
SET(CMAKE_MODULE_PATH
    ${COMP_MODULE_PATH}
)

IF(WIN32)
    SET(CPACK_GENERATOR "ZIP")
ELSE()
    SET(CPACK_GENERATOR "TGZ;TBZ2")
ENDIF()

# Enable the CPack module for building installers.
INCLUDE(CPack)

# Utilities to add and remove compiler flags.
INCLUDE(${COMP_MODULE_PATH}/flags.cmake)

# Utilities for building with MSVC.
INCLUDE(${COMP_MODULE_PATH}/msvc.cmake)

# Option for the static runtime on Windows.
OPTION(USE_STATIC_RUNTIME "Use the static MSVC runtime." OFF)

# Make sure MSVC uses the right runtime.
IF(USE_STATIC_RUNTIME)
    MSVC_RUNTIME(STATIC)
ELSE()
    MSVC_RUNTIME(DYNAMIC)
ENDIF()

# http://stackoverflow.com/questions/14933172/
IF("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    # Require at least GCC 4.9.
    IF(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.9)
        MESSAGE(FATAL_ERROR "GCC version must be at least 4.9!")
    ENDIF()

    ADD_COMPILER_FLAGS(AUTO -fno-strict-aliasing)
ELSEIF("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    SET(SPECIAL_COMPILER_FLAGS "-stdlib=libc++")

    # Require at least Clang 3.4.
    IF(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.4)
        MESSAGE(FATAL_ERROR "Clang version must be at least 3.4!")
    ENDIF()
ELSEIF("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    # There is nothing special needed for MSVC.
ELSE()
    MESSAGE(WARNING "You are using an unsupported compiler!")
ENDIF()

INCLUDE(${COMP_MODULE_PATH}/DetermineOS.cmake)

# If the build should be optimized.
OPTION(BUILD_OPTIMIZED "Build an optimized release of the server." ON)

# Include all build code for external projects.
INCLUDE(${COMP_MODULE_PATH}/external.cmake)

#
# Install for each external dependency.
#

INSTALL(DIRECTORY ${GSL_INCLUDE_DIRS} DESTINATION gsl)

ExternalProject_Get_Property(zlib-lib INSTALL_DIR)

INSTALL(DIRECTORY ${INSTALL_DIR}/lib DESTINATION zlib)
INSTALL(DIRECTORY ${INSTALL_DIR}/include DESTINATION zlib)

IF(NOT USE_SYSTEM_OPENSSL)
    ExternalProject_Get_Property(openssl INSTALL_DIR)

    INSTALL(DIRECTORY ${INSTALL_DIR}/lib DESTINATION openssl)
    INSTALL(DIRECTORY ${INSTALL_DIR}/include DESTINATION openssl)
ENDIF(NOT USE_SYSTEM_OPENSSL)

ExternalProject_Get_Property(mariadb INSTALL_DIR)

INSTALL(DIRECTORY ${INSTALL_DIR}/lib DESTINATION mariadb)
INSTALL(DIRECTORY ${INSTALL_DIR}/include DESTINATION mariadb)

ExternalProject_Get_Property(ttvfs-ex INSTALL_DIR)

INSTALL(DIRECTORY ${INSTALL_DIR}/bin DESTINATION ttvfs)
INSTALL(DIRECTORY ${INSTALL_DIR}/lib DESTINATION ttvfs)
INSTALL(DIRECTORY ${INSTALL_DIR}/include DESTINATION ttvfs)

ExternalProject_Get_Property(physfs-lib INSTALL_DIR)

INSTALL(DIRECTORY ${INSTALL_DIR}/lib DESTINATION physfs)
INSTALL(DIRECTORY ${INSTALL_DIR}/include DESTINATION physfs)

ExternalProject_Get_Property(civet INSTALL_DIR)

INSTALL(DIRECTORY ${INSTALL_DIR}/lib DESTINATION civet)
INSTALL(DIRECTORY ${INSTALL_DIR}/include DESTINATION civet)

ExternalProject_Get_Property(squirrel3 INSTALL_DIR)

INSTALL(DIRECTORY ${INSTALL_DIR}/lib DESTINATION squirrel3)
INSTALL(DIRECTORY ${INSTALL_DIR}/include DESTINATION squirrel3)

INSTALL(DIRECTORY ${ASIO_INCLUDE_DIRS} DESTINATION asio)

ExternalProject_Get_Property(tinyxml2-ex INSTALL_DIR)

INSTALL(DIRECTORY ${INSTALL_DIR}/lib DESTINATION tinyxml2)
INSTALL(DIRECTORY ${INSTALL_DIR}/include DESTINATION tinyxml2)

ExternalProject_Get_Property(googletest INSTALL_DIR)

INSTALL(DIRECTORY ${INSTALL_DIR}/lib DESTINATION googletest)
INSTALL(DIRECTORY ${INSTALL_DIR}/include DESTINATION googletest)

ExternalProject_Get_Property(jsonbox-ex INSTALL_DIR)

INSTALL(DIRECTORY ${INSTALL_DIR}/lib DESTINATION jsonbox)
INSTALL(DIRECTORY ${INSTALL_DIR}/include DESTINATION jsonbox)
