# vim: syntax=dockerfile filetype=dockerfile
FROM ubuntu:16.04
MAINTAINER John Hughes <johughes@tesla.com>

ENV USER=docker LOGNAME=docker MPLBACKEND=PDF

# Patch libipopt
ADD libipopt.patch /

RUN apt-get -y update \
  && apt-get -y install --no-install-recommends \
    build-essential \
    python \
    python-numpy \
    python-all-dev \
    python-jpype \
    python-pip \
    python-lxml \
    python-numpy \
    python-scipy \
    python-matplotlib \
    cython \
    cmake \
    make \
    ant \
    patch \
    coinor-libipopt-dev \
    coinor-libipopt1v5 \
    gfortran \
    openjdk-9-jdk-headless \
    subversion \
    openssh-client \
    zlib1g-dev \
    libnss-wrapper \
  && pip install --upgrade pip \
  && patch -N -p0 < libipopt.patch \

  # Build and install JModelica
  && mkdir -p /tmp \
  && svn export https://svn.jmodelica.org/branches/stable /tmp/JModelica.org \
  && cd /tmp/JModelica.org \
  && mkdir build \
  && cd build \
  && ../configure --with-ipopt=/usr \
  && make install \

  # Add the docker user
  && groupadd 1001 -g 1001 \
  && groupadd 1000 -g 1000 \
  && useradd -ms /bin/bash docker -g 1001 -G 1000 \
  && echo "docker:docker" | chpasswd \
  && adduser docker sudo \
  && echo "docker ALL= NOPASSWD: ALL\n" >> /etc/sudoers \

  # Cleanup
  && apt-get clean && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/* \
            /tmp/* \
            /var/tmp/*

# Set up TINI init
ENV TINI_VERSION v0.13.2
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
 && gpg --verify /tini.asc
RUN chmod +x /tini

COPY entrypoint-script.sh /
ENTRYPOINT ["/tini", "--", "/entrypoint-script.sh"]

