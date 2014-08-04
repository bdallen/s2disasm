#!/bin/bash

[[ ! -d bin ]] && mkdir bin

if [[ ! -f bin/s2p2bin ]]; then
	echo "Compiling s2p2bin..."
	g++ -O3 -s -o bin/s2p2bin build_source/s2p2bin.cpp build_source/KensSaxComp/S-Compressor.cpp &> /dev/null
fi

if [[ ! -f bin/fixpointer ]]; then
	echo "Compiling fixpointer..."
	g++ -O3 -s -o bin/fixpointer build_source/fixpointer.cpp &> /dev/null
fi

if [[ ! -f bin/fixheader ]]; then
	echo "Compiling fixheader..."
	g++ -O3 -s -o bin/fixheader build_source/fixheader.cpp &> /dev/null
fi

[[ -f s2built.bin ]] && mv -f s2built.bin s2built.prev.bin
rm -f s2.p s2.h s2.log

debug_syms=""
print_err="-E -q"

for n in `seq 1 2`; do
	if [[ "$1" == "-ds" ]]; then
		debug_syms="-g MAP"
		echo "Will generate debug symbols"
	elif [[ "$1" == "-pe" ]]; then
		print_err=""
		echo "Selected detailed assembler output"
	fi
	shift
done

echo Assembling...

asl -xx -c $debug_syms $print_err -A -U s2.asm

if [[ -f s2.log ]]; then
	echo
	echo "*****************************************"
	echo "*                                       *"
	echo "*   There were build errors/warnings.   *"
	echo "*                                       *"
	echo "*****************************************"
	echo
	cat s2.log
	exit 1
fi

[[ -f s2.p ]] && bin/s2p2bin s2.p s2built.bin s2.h
[[ -f s2built.bin ]] && bin/fixpointer s2.h s2built.bin
[[ -f s2built.bin ]] && bin/fixheader s2built.bin

