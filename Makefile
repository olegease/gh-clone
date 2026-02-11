.PHONY: usage cmake ninja ctest clean allin build tests

usage:
	cat Makefile.usage.txt

cmake:
	cmake -B build/ -GNinja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

ninja:
	ninja -C build/

ctest:
	ctest --test-dir build/ --output-on-failure

clean:
	rm -rf build/ && git restore build/.gitignore

allin:
	make clean && make cmake && make ninja && make ctest

build:
	make cmake && make ninja

tests:
	make ninja && make ctest
