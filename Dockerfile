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

WORKDIR /srv

# install boost
RUN wget -O boost_1_61_0.tar.bz2 https://sourceforge.net/projects/boost/files/boost/1.61.0/boost_1_61_0.tar.bz2/download \
  && tar xf boost_1_61_0.tar.bz2 \
  && rm boost_1_61_0.tar.bz2 \
  && cd boost_1_61_0 \
  && ./bootstrap.sh --with-libraries=chrono,date_time,filesystem,iostreams,program_options,random,regex,serialization,signals,system,thread,wave \
  && ./b2 -j $(nproc) -sNO_BZIP2=1 install

# download rose
RUN git clone https://github.com/rose-compiler/rose

ENV ROSESRC=/srv/rose
ENV ROSEBLD=/srv/build
ENV BOOSTROOT=/usr/local
ENV LD_LIBRARY_PATH="$BOOSTROOT/lib:$LD_LIBRARY_PATH" 

WORKDIR $ROSESRC

RUN ln -s /usr/bin/python3 /usr/bin/python
RUN ./build

WORKDIR $ROSEBLD

RUN $ROSESRC/configure --prefix=/usr/local --enable-languages=c,c++ --with-boost=$BOOSTROOT
RUN make -j $(nproc)
RUN make install
