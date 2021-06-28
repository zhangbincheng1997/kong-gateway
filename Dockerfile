FROM kong:2.3.3-centos

USER root

RUN yum -y update

RUN yum install -y openssl openssl-devel gcc

RUN luarocks install --server=http://rocks.moonscript.org luajwt
