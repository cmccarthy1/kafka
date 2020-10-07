#!/bin/bash

mkdir cbuild

if [ "$TRAVIS_OS_NAME" == "osx" ]; then
  brew install librdkafka
  cp -r /usr/local/opt/librdkafka/lib ./cbuild
  cp -r /usr/local/opt/librdkafka/include ./cbuild
elif [ "$TRAVIS_OS_NAME" == "linux" ]; then
  git clone https://github.com/edenhill/librdkafka
  ./configure --install-deps
  make && make install
  cp -r $HOME/lib/* ./cbuild
  cp -r $HOME/include/* ./cbuild
else
  echo "$TRAVIS_OS_NAME is currently not supported"  
fi
