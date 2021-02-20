FROM opensuse/leap:15.2

RUN zypper -n ar -c -f -n 'repo-nsis' https://download.opensuse.org/repositories/windows:/mingw:/win32/openSUSE_Leap_15.2/ repo-nsis
RUN zypper -n ar -c -f -n 'repo-devel-tools-building' https://download.opensuse.org/repositories/devel:tools:building/openSUSE_Leap_15.2/ repo-devel-tools-building

RUN zypper --non-interactive --gpg-auto-import-keys ref
RUN zypper --non-interactive --gpg-auto-import-keys up -l -y

RUN zypper --non-interactive --gpg-auto-import-keys install \
    glibc glibc-extra glibc-locale glibc-i18ndata glibc-32bit gcc-c++ \
    git make cmake libtool pkg-config autoconf automake makeinfo meson ninja intltool \
    which patch wget curl gperf tar gzip bzip2 xz p7zip p7zip-full lzip zip unzip \
    gettext-tools gtk-doc ruby scons bison flex diffutils orc \
    linux-glibc-devel glibc-devel file-devel libopenssl-devel libffi-devel gdk-pixbuf-devel \
    python-base python3-base python3-setuptools python3-Mako \
    mingw32-cross-nsis

RUN mkdir -p /usr/src
RUN cd /usr/src/ && git clone https://github.com/jonaski/mxe-qt
RUN sed -i 's/MXE_TARGETS := .*/MXE_TARGETS := x86_64-w64-mingw32.static/g' /usr/src/mxe-qt/settings.mk
RUN cd /usr/src/mxe-qt && make -j4

