#!/bin/bash

##########################################################################
#
# CMake Configuration for OSSIM on Linux
#
# DO NOT RELOCATE THIS SCRIPT. Its location is used to resolve relative
# directory paths.
#
# Usage: <this_script_name> [<build_type>] 
#
# where the optional <build_type> is one of the following literals 
# (case-insensitive):
#
#     "release" (default), 
#     "debug", 
#     "relWithDebInfo", 
#     "minSizeRel",
#     "eclipse"
#
# If a build type = "eclipse" is specified, cmake will generate a Debug
# build environment along with Eclipse CDT4 project files (in the build
# directory) for importing as existing project.
#
# Instructions: Run this script to build the repository. This script can be
# run from any directory, but will assume a default relative directory
# heirarchy when searching for related items.
# 
# No env vars need to be predefined. The build output will be written to
# $OSSIM_DEV_HOME/build/<build_type> where $OSSIM_DEV_HOME is the top-level
# folder containing all OSSIM repositories (including this one).
#
# For customized output location, you can define the env var OSSIM_BUILD_DIR
# prior to running this script, and the output will be written there.
#
##########################################################################

# Uncomment following line to debug script line by line:
#set -x; trap read debug

# Fetch the build type from command line:
BUILD_TYPE_ARG=${1^^}
case "$BUILD_TYPE_ARG" in
  DEBUG)
      CMAKE_BUILD_TYPE="Debug"
      ;;
  ECLIPSE)
      CMAKE_BUILD_TYPE="Debug"
      ;;
  RELEASE)
      CMAKE_BUILD_TYPE="Release"
      ;;
  RELWITHDEBINFO)
      CMAKE_BUILD_TYPE="RelWithDebInfo"
      ;;
  MINSIZEREL)
      CMAKE_BUILD_TYPE="MinSizeRel"
      ;;
  *)
      CMAKE_BUILD_TYPE="Release"
esac

# Establish location of master CMakeLists.txt file. This is the cmake file
# used to build all OSSIM-related repos (plugins, tests, oms, etc)
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
pushd $SCRIPT_DIR/..
CMAKE_DIR=$PWD
#echo "@@@@@ CMAKE_DIR=$CMAKE_DIR"
popd

# Establish the top-level directory above repo containing this script
#echo "@@@@@ BEFORE OSSIM_DEV_HOME=$OSSIM_DEV_HOME"
if [ -z $OSSIM_DEV_HOME ]; then
  pushd $CMAKE_DIR/../..
  OSSIM_DEV_HOME=$PWD
  #echo "@@@@@ NEW OSSIM_DEV_HOME=$OSSIM_DEV_HOME"
  popd
#else
  #echo "@@@@@ OSSIM_DEV_HOME UNCHANGED!"
fi 

# Establish CMake's output build directory:
if [ -z $OSSIM_BUILD_DIR ]; then
  if [ $BUILD_TYPE_ARG == "ECLIPSE" ]; then
     pushd $OSSIM_DEV_HOME/..
     OSSIM_BUILD_DIR=$PWD/ossimlabs_eclipse_build
     popd
  else
    OSSIM_BUILD_DIR=$OSSIM_DEV_HOME/build
  fi
fi

# Additional stuff for ECLIPSE CDT4 users:
CMAKE_G_ARG="Unix Makefiles"
if [ $BUILD_TYPE_ARG == "ECLIPSE" ]; then
  CMAKE_G_ARG="Eclipse CDT4 - Unix Makefiles"
  cp -f $CMAKE_DIR/CMakeLists.txt $OSSIM_DEV_HOME
  CMAKE_DIR=$OSSIM_DEV_HOME
fi

#echo "@@@@@ OSSIM_BUILD_DIR=$OSSIM_BUILD_DIR"
mkdir -p $OSSIM_BUILD_DIR
pushd $OSSIM_BUILD_DIR
rm CMakeCache.txt

# Check for ENV vars set to override hardcoded plugins switches here:
if [ -z $BUILD_MRSID_PLUGIN ]; then
  BUILD_MRSID_PLUGIN=OFF
fi
if [ -z $BUILD_KAKADU_PLUGIN ]; then
  BUILD_KAKADU_PLUGIN=OFF
fi
if [ -z $BUILD_PDAL_PLUGIN ]; then
  BUILD_PDAL_PLUGIN=ON
fi
if [ -z $BUILD_GDAL_PLUGIN ]; then
  BUILD_GDAL_PLUGIN=ON
fi
if [ -z $BUILD_GEOPDF_PLUGIN ]; then
  BUILD_GEOPDF_PLUGIN=OFF
fi
if [ -z $BUILD_CNES_PLUGIN ]; then
  BUILD_CNES_PLUGIN=ON
fi
if [ -z $BUILD_HDF5_PLUGIN ]; then
  BUILD_HDF5_PLUGIN=ON
fi
if [ -z $BUILD_KML_PLUGIN ]; then
  BUILD_KML_PLUGIN=ON
fi
if [ -z $BUILD_OPENCV_PLUGIN ]; then
  BUILD_OPENCV_PLUGIN=OFF
fi
if [ -z $BUILD_OPENJPEG_PLUGIN ]; then
  BUILD_OPENJPEG_PLUGIN=OFF
fi
if [ -z $BUILD_PNG_PLUGIN ]; then
  BUILD_PNG_PLUGIN=ON
fi
if [ -z $BUILD_SQLITE_PLUGIN ]; then
  BUILD_SQLITE_PLUGIN=ON
fi

echo "Generating Makefiles in" $OSSIM_BUILD_DIR

# CMAKE command 
cmake -G "$CMAKE_G_ARG" \
-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
-DOSSIM_DEV_HOME=$OSSIM_DEV_HOME \
-DBUILD_CNES_PLUGIN=$BUILD_CNES_PLUGIN \
-DBUILD_GEOPDF_PLUGIN=$BUILD_GEOPDF_PLUGIN \
-DBUILD_GDAL_PLUGIN=$BUILD_GDAL_PLUGIN \
-DBUILD_HDF5_PLUGIN=$BUILD_HDF5_PLUGIN \
-DBUILD_KAKADU_PLUGIN=$BUILD_KAKADU_PLUGIN \
-DBUILD_KML_PLUGIN=$BUILD_KML_PLUGIN \
-DBUILD_MRSID_PLUGIN=$BUILD_MRSID_PLUGIN \
-DBUILD_OPENCV_PLUGIN=$BUILD_OPENCV_PLUGIN \
-DBUILD_OPENJPEG_PLUGIN=$BUILD_OPENJPEG_PLUGIN \
-DBUILD_PDAL_PLUGIN=$BUILD_PDAL_PLUGIN \
-DBUILD_PNG_PLUGIN=$BUILD_PNG_PLUGIN \
-DBUILD_SQLITE_PLUGIN=$BUILD_SQLITE_PLUGIN \
$CMAKE_DIR

popd

