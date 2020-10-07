#!/bin/bash

mkdir cbuild

if [ "$TRAVIS_OS_NAME" == "osx" ]; then
  brew install librdkafka
  cp -r /usr/local/opt/librdkafka/lib ./cbuild
  cp -r /usr/local/opt/librdkafka/include ./cbuild
elif [ "$TRAVIS_OS_NAME" == "linux" ]; then
  mkdir build && cd build
  git clone https://github.com/edenhill/librdkafka
  cd librdkafka
  ./configure && make && sudo make install
  cp -r /usr/local/lib/* ./cbuild
  cp -r /usr/local/include/* ./cbuild
  cd ../..
else
  echo "$TRAVIS_OS_NAME is currently not supported"  
fi
