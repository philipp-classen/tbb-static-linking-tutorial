#!/bin/bash
#
# Builds both a dynamically and statically linked binary of the
# TBB toy example in "example-tbb-app/example.cpp".
#
# Then it tests whether the binaries run on different Linux distributions.
# The statically linked binary is expected to work on all environments.
#


# The list of images against which the static and dynamically linked binaries are tested.
#
# By default, it only tests against the minimal Alpine distribution and ubuntu16:04,
# which is already used for building the binary.
test_images="ubuntu:16.04 alpine"

# If you want you can uncomment the line below to test against more distributions:
#test_images="alpine debian ubuntu:16.04 ubuntu hjd48/redhat fedora centos vguardiola/gentoo dock0/arch opensuse vbatts/slackware vcatechnology/linux-mint"

if [[ -z $(which docker 2> /dev/null) ]] ; then
    echo "ERROR: Docker is not installed."
    exit 1
fi

if docker ps > /dev/null 2> /dev/null ; then
    readonly docker="docker"
else
    readonly docker="sudo docker"
    echo "Docker needs to be run with sudo. The script will ask for the sudo password to continue."
fi

set -e

echo
echo "*** Cleaning up old state ***"
/bin/rm -f example-tbb-app/statically-linked-binary example-tbb-app/dynamically-linked-binary

echo
echo "*** Building binaries ***"

echo
echo "*** Build dynamically linked binary (on the host system) ***"
echo "(Assumes that compiler and TBB are installed on the host system.)"
(cd example-tbb-app && make dynamically-linked-binary)

if [[ -e example-tbb-app/dynamically-linked-binary ]] ; then 
    echo "Dynamically linked binary has been successfully created."
else
    echo "ERROR: Failed to build dynamically linked binary"
    exit 1
fi

echo
echo "*** Build statically linked binary ***"
$docker build . -t build-static-binary
$docker run -v $(pwd)/example-tbb-app:/output-dir build-static-binary

if [[ -e example-tbb-app/statically-linked-binary ]] ; then 
    echo "Statically linked binary has been successfully created."
else
    echo "ERROR: Failed to build statically linked binary"
    exit 1
fi

echo
echo "*** Testing whether the dynamically built binary works ***"
echo
echo "It should work on the host environment:"
example-tbb-app/dynamically-linked-binary || { echo "ERROR: Failed to run the dynamically linked binary on the host system!" ; exit 1 ; }

echo
echo "Now run the dynamically linked script in a new Linux environments without any installed packages."
echo "As TBB is not installed, it is expected to fail."

for image in $test_images ; do
    echo
    echo "Testing dynamically linked binary in $image..."
    $docker run -v $(pwd)/example-tbb-app/dynamically-linked-binary:/binary $image /binary || echo "As expected, the binary failed to execute in $image"
done

echo
echo "*** Testing whether the statically built binary works ***"
echo
echo "It should work on the host environment:"
example-tbb-app/dynamically-linked-binary || { echo "ERROR: Failed to run the statically linked binary on the host system!" ; exit 1 ; }

echo "Now run the statically linked binary in a new Linux environments without any installed packages."
echo "Even though TBB is not installed, it is expected to worked as all "
echo "dependences are part of the statically linked binary."
echo
for image in $test_images ; do
    echo
    echo "Testing statically linked binary in $image..."
    $docker run -v $(pwd)/example-tbb-app/statically-linked-binary:/binary $image /binary || { echo "ERROR: Failed to run the statically linked binary in $image!" ; exit 1 ; }
done

echo
echo "SUCCESS: All tests passed"
