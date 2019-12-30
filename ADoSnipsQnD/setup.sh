#!/bin/sh
#
echo "... setting up Julia ecosystem"

if ! [ -e /usr/local/bin/julia ] ; then
  echo "The Julia proramming language is missing on the computer."
  echo "See https://julialang.org/downloads/ for installation instructions"
  echo "and create a symbolic to the julia executable link at /usr/local/bin/"
  echo " "
fi

# install Julia dependencies:
#
julia -e 'using Pkg;  Pkg.add("JSON"); Pkg.add("StatsBase"); Pkg.update(); Pkg.status()'


# check debian packages:
#
check_package () {
  PACK=$1
  dpkg -l $PACK
  STATUS=$?

  if [ $STATUS -ne 0 ] ; then
    echo " "
    echo "Package $PACK is not installed!"
    echo "Please install manually on Raspberry pi with:"
    echo "   $ sudo apt-get install $PACK"
  fi
}

# check mosquitto installation:
#
echo "... checking mosquitto installation"
check_package mosquitto
check_package mosquitto-clients


# eof.
