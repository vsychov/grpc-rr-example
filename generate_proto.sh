#!/bin/bash
RED='\033[0;31m'
if [ ! -f "/.dockerenv" ]; then
    echo -e $RED
    echo '--------------------'
    echo 'This command should be executed inside docker container, for prevent problem with generation.'
    echo '--------------------'
    exit 1;
fi

rm -rf assets/js/proto/*
rm -rf src/Proto/*
rm -rf /var/proto/*.proto
rm -rf .proto_tmp/*
cp proto/*.proto /var/proto/
mkdir -p .proto_tmp

protoc \
--plugin=protoc-gen-ts=./node_modules/.bin/protoc-gen-ts \
--js_out=import_style=commonjs,binary:assets/js/proto \
--ts_out=service=grpc-web:assets/js/proto \
-I/var/proto/ \
/var/proto/*.proto

protoc \
--php_out=.proto_tmp \
--php-grpc_out=.proto_tmp \
-I/var/proto/ \
/var/proto/*.proto

mv .proto_tmp/App/Proto/* src/Proto/
rm -rf .proto_tmp