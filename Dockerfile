# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie

# set version label
ARG BUILD_DATE
ARG WINEGUI_VERSION
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=WineGUI \
    NO_FULL=true \
    SELKIES_DESKTOP=true \
    PIXELFLUX_WAYLAND=true

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/winegui-logo.png && \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    caja \
    gpg \
    libgles2-mesa-dev \
    p7zip \
    unzip \
    wget && \
  dpkg --add-architecture i386 && \
  mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://dl.winehq.org/wine-builds/winehq.key \
    | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key - && \
  curl -o \
    /etc/apt/sources.list.d/winehq-trixie.sources -L \
    https://dl.winehq.org/wine-builds/debian/dists/trixie/winehq-trixie.sources && \
  apt-get update && \
  apt-get install -y --install-recommends \
    winehq-stable \
    winetricks && \
  echo "**** install winegui ****" && \
  if [ -z ${WINEGUI_VERSION+x} ]; then \
    WINEGUI_VERSION=$(curl -sX GET "https://api.github.com/repos/winegui/WineGUI/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/winegui.deb -L \
    "https://github.com/winegui/WineGUI/releases/download/${WINEGUI_VERSION}/WineGUI-${WINEGUI_VERSION}-trixie.deb" && \
  apt install -y \
    /tmp/winegui.deb && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /tmp/* \
    /usr/share/applications/caja-autorun-software.desktop \
    /usr/share/applications/caja-computer.desktop \
    /usr/share/applications/caja.desktop \
    /usr/share/applications/caja-file-management-properties.desktop \
    /usr/share/applications/caja-folder-handler.desktop \
    /usr/share/applications/caja-home.desktop \
    /usr/share/applications/debian-uxterm.desktop \
    /usr/share/applications/debian-xterm.desktop \
    /usr/share/applications/footclient.desktop \
    /usr/share/applications/foot-server.desktop \
    /usr/share/applications/mate-about.desktop \
    /usr/share/applications/mate-color-select.desktop \
    /usr/share/applications/st.desktop \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3001

VOLUME /config
