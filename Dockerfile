FROM ubuntu:trusty

# install dependencies
RUN apt-get update && apt-get install -y \
  automake \
  bison \
  build-essential \
  flex \
  gfortran \
  ghostscript \
  git \
  g++ \
  libtool \
  openjdk-7-jre \
  wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV WORKSPACE=/srv
WORKDIR $WORKSPACE

# install boost
RUN wget -O boost_1_61_0.tar.bz2 https://sourceforge.net/projects/boost/files/boost/1.61.0/boost_1_61_0.tar.bz2/download \
  && tar xf boost_1_61_0.tar.bz2 \
  && rm boost_1_61_0.tar.bz2 \
  && cd boost_1_61_0 \
  && ./bootstrap.sh --with-libraries=chrono,date_time,filesystem,iostreams,program_options,random,regex,serialization,signals,system,thread,wave \
  && ./b2 -j $(nproc) -sNO_BZIP2=1 install \
  && rm -rf $WORKSPACE

ENV ROSESRC=$WORKSPACE/rose
ENV ROSEBLD=$WORKSPACE/build
ENV BOOSTROOT=/usr/local
ENV LD_LIBRARY_PATH="$BOOSTROOT/lib:$LD_LIBRARY_PATH" 

# pre-install rose
RUN git clone https://github.com/rose-compiler/rose $ROSESRC \
  && ln -s /usr/bin/python3 /usr/bin/python \
  && cd $ROSESRC \
  && ./build \
# cd ROSEBLD dir
  && mkdir $ROSEBLD \
  && cd $ROSEBLD \
  && $ROSESRC/configure --prefix=/usr/local --enable-languages=c,c++ --with-boost=$BOOSTROOT \
  && make -j $(nproc) \
  && make install \
  && rm -rf $WORKSPACE
