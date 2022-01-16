FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        curl \
        wget \
        unzip \
        tree \
        gpg \
        libio-tee-perl \
        neovim 

###########################
# Install specific cmake version
###########################
ARG CMAKE_VERSION=3.22
ARG CMAKE_BUILD=1

RUN mkdir -p /home/root/temp
WORKDIR /home/root/temp
RUN wget https://cmake.org/files/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.${CMAKE_BUILD}.tar.gz
RUN tar -xzvf cmake-${CMAKE_VERSION}.${CMAKE_BUILD}.tar.gz
WORKDIR cmake-${CMAKE_VERSION}.${CMAKE_BUILD}/
RUN apt-get install -y \
        openssl \
        libssl-dev
RUN ./bootstrap && make -j$(nproc) && make install
WORKDIR /
RUN rm -r /home/root/temp
RUN echo "cmake --version = $(cmake --version)"


# How to install the latest version of cmake with apt automatically 
#RUN apt-get remove --purge --auto-remove cmake
#
#RUN apt-get update && \
#    apt-get install -y \
#        software-properties-common \
#        lsb-release && \
#    apt-get clean all
#RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2 >/dev/null \
#    | gpg --dearmor - \
#    | tee /etc/apt/trusted.gpg.d/kitware.gpg > /dev/null
#
#RUN apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main"
#
#RUN apt-get update && apt-get install -y kitware-archive-keyring 
#RUN rm /etc/apt/trusted.gpg.d/kitware.gpg
#RUN apt-get update
#RUN apt-get install -y cmake



WORKDIR /home/root/

# We don't care about the timezone, but pkgconfig does, so just add a dummy one
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get install -y \
    pkg-config

COPY . .
RUN [ -d build ] && rm -r build
RUN ./scripts/build-and-test.sh

