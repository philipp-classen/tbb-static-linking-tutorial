#
# This only builds a dynamically linked binary.
# To build the statically linked binary, have a look at ../Dockerfile.
#
dynamically-linked-binary: example.cpp
	g++ -std=c++14 -O3 -g -o dynamically-linked-binary example.cpp -ltbb -lpthread
