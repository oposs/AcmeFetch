# The build environment of the acmefetch packages.
#
# ri-release-distro-packages builds the build-deps stage once per release
# with --build-arg BASE=<image of that release> and runs ./bootstrap,
# ./configure, make, make check and make install DESTDIR=/stage in it, with
# the checkout at /src. make downloads cpanminus, Carton and the modules
# named in cpanfile from CPAN. Net::SSLeay and Crypt::OpenSSL::X509 are XS
# modules and build against the release's OpenSSL, hence the compiler and the
# OpenSSL and zlib headers. acmefetch and its test call the openssl command.
# The image is built without a context: it names packages and nothing else.
ARG BASE=docker.io/library/debian:13
FROM ${BASE} AS build-deps

RUN set -eu; \
    . /etc/os-release; \
    case " ${ID} ${ID_LIKE:-} " in \
    *" debian "*|*" ubuntu "*) \
        apt-get update; \
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            autoconf automake make perl curl ca-certificates gzip tar unzip gcc libc6-dev \
            libcrypt-dev libssl-dev zlib1g-dev openssl; \
        rm -rf /var/lib/apt/lists/* ;; \
    *" rhel "*|*" fedora "*|*" centos "*) \
        dnf install -y autoconf automake make perl perl-devel curl gzip tar unzip gcc \
            openssl openssl-devel zlib-devel; \
        dnf clean all ;; \
    *" alpine "*) \
        apk add --no-cache autoconf automake make perl perl-dev perl-utils build-base \
            curl wget perl-io-socket-ssl ca-certificates gzip tar unzip \
            openssl openssl-dev zlib-dev ;; \
    *) echo "Containerfile: no package list for ${ID}" >&2; exit 1 ;; \
    esac
