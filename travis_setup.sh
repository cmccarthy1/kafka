#!/bin/bash

mkdir cbuild

if [ "$TRAVIS_OS_NAME" == "osx" ]; then
  brew install librdkafka
  cp -r /usr/local/opt/librdkafka/lib ./cbuild
  cp -r /usr/local/opt/librdkafka/include ./cbuild
elif [ "$TRAVIS_OS_NAME" == "linux" ]; then
  git clone https://github.com/edenhill/librdkafka
  cd librdkafka
  ./configure --prefix=../cbuild --disable-sasl --disable-lz4 --disable-ssl --mbits=64
  make
  sudo make install
  cd ..
elif [ "$TRAVIS_OS_NAME" == "windows" ]; then  
  curl -o ./nuget.exe -L https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
  chmod a+x ./nuget.exe
  ./nuget.exe install librdkafka.redist -version 1.4.4
  mkdir cbuild/lib
  cp librdkafka.redist.1.4.4/build/native/lib/win/x64/win-x64-Release/v120/* cbuild/lib
  cp -r librdkafka.redist.1.4.4/build/native/include ./cbuild
else
  echo "$TRAVIS_OS_NAME is currently not supported"  
fi
