#!/bin/sh

apt purge openssl libssl-dev -y

apt autoremove -y

apt install -y build-essential wget git

wget -O openssl-3.5.1.tar.gz https://github.com/openssl/openssl/releases/download/openssl-3.5.1/openssl-3.5.1.tar.gz

tar -zxvf openssl-3.5.1.tar.gz

cd openssl-3.5.1

./config --prefix=/usr/local/openssl-3.5.1 enable-quic shared zlib-dynamic

make -j$(nproc)

make install_sw

# 更新库链接

tee /etc/ld.so.conf.d/openssl-3.5.1.conf <<< "/usr/local/openssl-3.5.1/lib64"

ldconfig

# 替换系统 OpenSSL（谨慎操作！建议仅限测试环境）

rm -f /usr/bin/openssl

ln -s /usr/local/openssl-3.5.1/bin/openssl /usr/bin/openssl

# 验证版本与 QUIC 支持

openssl version  # 应输出 "OpenSSL 3.5.1"

apt install apt-transport-https ca-certificates

openssl list -providers | grep -i quic  # 检查是否包含 QUIC 提供者

DEBIAN_VER=$(cat /etc/os-release |  grep 'VERSION=' | awk -F\" {'print $2'} | awk {'print $1'})

apt remove -y --purge haproxy*

apt autoremove -y

wget -O pcre2-10.45.tar.bz2 https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.45/pcre2-10.45.tar.bz2

tar -xjf pcre2-10.45.tar.bz2

cd pcre2-10.45

./configure

make -j$(nproc)

make install

ldconfig

cd

wget -O lua-5.4.8.tar.gz https://www.lua.org/ftp/lua-5.4.8.tar.gz

tar -xvzf lua-5.4.8.tar.gz

cd lua-5.4.8

make linux

make install

cd

git clone https://git.haproxy.org/git/haproxy.git

cd haproxy

export SSL_INC="/usr/local/openssl-3.5.1/include"

export SSL_LIB="/usr/local/openssl-3.5.1/lib64"

make clean

make -j$(nproc) TARGET=linux-glibc USE_OPENSSL=1 USE_QUIC=1 USE_PCRE2=1 USE_PCRE2_JIT=1 USE_LUA=1 SSL_INC="$SSL_INC" SSL_LIB="$SSL_LIB" CC="gcc"

make install

useradd -r -s /sbin/nologin haproxy

setcap cap_net_bind_service=+ep /usr/local/sbin/haproxy

exit 0
