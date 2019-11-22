# Copyright (c) 2019 FEROX YT EIRL, www.ferox.yt <devops@ferox.yt>
# Copyright (c) 2019 Jérémy WALTHER <jeremy.walther@golflima.net>
# See <https://github.com/frxyt/docker-xrdp> for details.

FROM debian:buster

LABEL maintainer="Jérémy WALTHER <jeremy@ferox.yt>"

# Install required packages to run
RUN     DEBIAN_FRONTEND=noninteractive apt-get update \
    &&  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --fix-missing --no-install-recommends \
            ca-certificates \
            curl \
            dbus-x11 \
            gnupg \
            openssh-server \
            sudo \
            supervisor \
            tigervnc-standalone-server \
            vim \
            xrdp \
    &&  apt-get clean -y && apt-get clean -y && apt-get autoclean -y && rm -r /var/lib/apt/lists/*
    
ENV FRX_APTGET_DISTUPGRADE= \
    FRX_APTGET_INSTALL= \
    FRX_INIT_CMD= \
    FRX_START_CMD= \
    FRX_XRDP_CERT_SUBJ='/C=FX/ST=None/L=None/O=None/OU=None/CN=localhost' \
    FRX_XRDP_USER_NAME=debian \
    FRX_XRDP_USER_PASSWORD=ChangeMe \
    FRX_XRDP_USER_SUDO=1 \
    FRX_XRDP_USER_GID=1000 \
    FRX_XRDP_USER_UID=1000 \
    TZ=Etc/UTC

COPY build/start                /usr/local/sbin/frx-start
COPY build/supervisord.conf     /etc/supervisor/supervisord.conf
COPY build/xrdp.ini             /etc/xrdp/xrdp.ini

RUN     echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/ALL \
    &&  sed -e 's/^#\?\(PermitRootLogin\)\s*.*$/\1 no/' \
            -e 's/^#\?\(PasswordAuthentication\)\s*.*$/\1 yes/' \
            -e 's/^#\?\(PermitEmptyPasswords\)\s*.*$/\1 no/' \
            -e 's/^#\?\(PubkeyAuthentication\)\s*.*$/\1 yes/' \
            -i /etc/ssh/sshd_config \
    &&  mkdir -p /run/sshd \
    &&  rm -f /etc/xrdp/cert.pem /etc/xrdp/key.pem /etc/xrdp/rsakeys.ini \
    &&  rm -f /etc/ssh/ssh_host_*

COPY Dockerfile LICENSE README.md /frx/

ARG DOCKER_TAG
ARG SOURCE_BRANCH
ARG SOURCE_COMMIT
COPY build/desktop /usr/local/sbin/frx-desktop
RUN     echo "[frxyt/xrdp:${DOCKER_TAG}] <https://github.com/frxyt/docker-xrdp>" > /frx/version \
    &&  echo -e "[Version: ${SOURCE_BRANCH}@${SOURCE_COMMIT}]\n" >> /frx/version \
    &&  /usr/local/sbin/frx-desktop ${DOCKER_TAG}

EXPOSE 22
EXPOSE 3389

VOLUME [ "/home" ]
WORKDIR /home

CMD [ "/usr/local/sbin/frx-start" ]