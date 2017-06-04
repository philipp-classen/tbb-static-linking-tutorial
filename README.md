# TBB static linking tutorial

TBB does not provide statically linked libraries. Here is the
[link to the rationales](https://www.threadingbuildingblocks.org/faq/11?page=1).

It is still unofficially supported to build statically linked binaries.
The trick is to build TBB manually with `make extra_inc=big_iron.inc`.
In this walkthrough, you will see how that is done.

In the subdirectory `example-tbb-app`, there is a toy example which has
dependences to TBB and pthread. There is a Makefile which can be used to
build a dynamically linked binary.

The steps to build a statically linked version can be found in the
Dockerfile.

## Testing on different Linux distributions

To verify that the statically linked binaries is portable, you
can use the `test-binaries.sh` shell script. Internally, it uses Docker
to simulate different Linux distributions (the list of Linux images
is at the begin of the shell script and can be modified).

First, it will build a dynamically linked version of the example application
and will try to run it on the host system and the Linux images. As expected,
it will work on your host machine, but will fail on the other Linux distributions
because TBB is not installed there.

Next, it tests the statically linked binary. It should work both on the host
system and all Linux distributions simulated by the Docker images.

## Making the example more realistic

The toy example should not be more complicated than needed, but it should
cover the critical dependencies. Otherwise, it will not help to create a
statically linked binary of a real-world example.

If you notice that important TBB dependencies are not covered, you can extend
the `example.cpp` file by adding more calls to the TBB API, and run the
`test-binaries.sh` script again. If the recipe in the Dockfile is correct,
it should still work (both locally and for the Docker images). Otherwise, you found a bug.

Bug reports and pull requests are welcome. :-)
