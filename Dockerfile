FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

RUN apt-get update
RUN apt-get -y install sudo && \
    sudo apt-get -y install git && \
    sudo apt-get -y install vim && \
    sudo apt-get -y install man && \
    sudo apt-get -y install unzip && \
    sudo apt-get -y install zlib1g-dev libzip-dev libboost-filesystem-dev && \
    sudo apt-get -y install wget

RUN mkdir /workspace
WORKDIR /workspace

# Download cmake
RUN wget -nv https://github.com/Kitware/CMake/releases/download/v3.15.3/cmake-3.15.3-Linux-x86_64.tar.gz
RUN tar zxvf cmake-3.15.3-Linux-x86_64.tar.gz
RUN git clone https://github.com/lightvector/KataGo.git --depth 1

WORKDIR KataGo/cpp
RUN /workspace/cmake-3.15.3-Linux-x86_64/bin/cmake . -DBUILD_MCTS=1 -DUSE_BACKEND=CUDA
RUN make

# Runtime image
FROM nvidia/cuda:10.0-cudnn7-runtime

RUN mkdir /app
WORKDIR /app

COPY --from=0 /workspace/KataGo/cpp/katago .

ENTRYPOINT [ "./katago" ]
