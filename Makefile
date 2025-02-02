.PHONY: api

default: clean compile compile-storage

ARCH=$(shell /usr/bin/uname -m)
PWD=$(shell pwd)
LIGO=docker run --rm -v ${PWD}:${PWD} -w ${PWD} ligolang/ligo:0.40.0

clean:
	rm -rf ./compilation
	mkdir ./compilation

compile:
	${LIGO} compile contract src/increment.mligo -o compilation/contract.tz

compile-storage:
	${LIGO} compile storage src/increment.mligo default_storage -o compilation/storage.tz

deploy:
	./tools/with_venv.sh python ./tools/originate.py

env:
	virtualenv .venv
ifeq (${ARCH}, arm64)
	CFLAGS="-I/opt/homebrew/Cellar/gmp/6.2.1_1/include/ -L/opt/homebrew/Cellar/gmp/6.2.1_1/lib/" \
	LIB_DIR="/opt/homebrew/Cellar/libsecp256k1/0.1/lib" \
	INCLUDE_DIR="/opt/homebrew/Cellar/libsecp256k1/0.1/include" \
	./tools/with_venv.sh pip install --no-cache-dir pytezos
else
	./tools/with_venv.sh pip install --no-cache-dir pytezos
endif

test:
	${LIGO} run dry-run --entry-point main src/increment.mligo 'Increment(5)' '4'
