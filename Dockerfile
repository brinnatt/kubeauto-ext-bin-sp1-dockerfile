# Building extra binaries needed by kubeauto-ext-bin-dockerfile
# @author: Brinnatt
# @repo: https://github.com/brinnatt/kubeauto-ext-bin-sp1-dockerfile
# @ref: https://github.com/brinnatt/kubeauto-ext-bin-dockerfile

FROM rockylinux/rockylinux:8.10 as rpm_rockylinux810

ENV NGINX_VERSION=1.28.0
ENV CHRONY_VERSION 4.7
ENV CHRONY_DOWNLOAD_URL "https://chrony-project.org/releases/chrony-${CHRONY_VERSION}.tar.gz"
ENV KEEPALIVED_VERSION 2.3.4
ENV KEEPALIVED_DOWNLOAD_URL "http://keepalived.org/software/keepalived-${KEEPALIVED_VERSION}.tar.gz"

RUN yum install -y \
      gcc \
      make \
      openssl \
      openssl-devel \
 && curl -o nginx.tar.gz -SL http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
 && tar -xzf nginx.tar.gz -C /tmp/ \
 && cd /tmp/nginx-* \
 && ./configure --with-stream \
                --without-http \
                --without-http_uwsgi_module \
                --without-http_scgi_module \
                --without-http_fastcgi_module \
 && make && make install \
 && cd / \
 && curl -o chrony.tar.gz -SL $CHRONY_DOWNLOAD_URL \
 && tar xzf chrony.tar.gz -C /tmp/ \
 && cd /tmp/chrony* \
 && ./configure \
        --without-editline \
        --disable-sechash \
        --disable-nts \
        --disable-ipv6 \
        --disable-privdrop \
        --without-libcap \
        --without-seccomp \
        --disable-asyncdns \
        --disable-cmdmon \
  && make && make install \
  && cd / \
  && curl -o keepalived.tar.gz -SL $KEEPALIVED_DOWNLOAD_URL \
  && tar xzf keepalived.tar.gz -C /tmp/ \
  && cd /tmp/keepalived* \
  && ./configure \
		--disable-dynamic-linking \
		--disable-FEATURE \
      --disable-lvs \
		--disable-vrrp-auth \
		--disable-routes \
		--disable-linkbeat \
		--disable-iptables \
		--disable-libipset-dynamic \
		--disable-nftables \
		--disable-hardening \
		--with-init=systemd \
  && make && make install

FROM alpine:3.16

ENV EXT_BUILD_VER=1.3.0

COPY --from=rpm_rockylinux810 /usr/local/nginx/sbin/nginx /ext-bin/
COPY --from=rpm_rockylinux810 /usr/local/sbin/chronyd /ext-bin/
COPY --from=rpm_rockylinux810 /usr/local/sbin/keepalived /ext-bin/

CMD [ "tail", "-f", "/dev/null" ]