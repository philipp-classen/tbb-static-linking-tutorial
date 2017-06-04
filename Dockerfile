FROM ubuntu:16.04

RUN \
  apt-get update && \
  apt-get install -y \
      build-essential \
      libtbb-dev \
      wget \
    && \
  rm -rf /var/lib/apt/lists/*

# Install TBB and build it with "big_iron"
RUN wget https://github.com/01org/tbb/archive/2017_U6.tar.gz && \
    tar xzfv 2017_U6.tar.gz && \
    cd tbb-2017_U6 && \
    make extra_inc=big_iron.inc

# Now build the example application.
#
# Notes:
# - Call g++ with the "-static" switch
# - Link against tbb ("-ltbb") and pthread ("-lpthread")
# - Reference all ".o" files from the manually build TBB version
# - Depending on your real-world example, you might also need to
#   pass "-pthread" to gcc as well. In this example, it is not needed.
#
COPY example-tbb-app/example.cpp /example-tbb-app/example.cpp
RUN cd /example-tbb-app && \
    g++ -std=c++14 -O3 -g -o statically-linked-binary example.cpp /tbb-2017_U6/build/linux*release/*.o -static -L /tbb-2017_U6/build/linux*release -ltbb -lpthread && \
    strip statically-linked-binary

CMD ["cp", "/example-tbb-app/statically-linked-binary", "/output-dir/statically-linked-binary"]
