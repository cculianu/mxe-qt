# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qt6base
$(PKG)_WEBSITE  := https://www.qt.io/
$(PKG)_DESCR    := Qt 6 Base
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 6.0.1
$(PKG)_CHECKSUM := 8d2bc1829c1479e539f66c2f51a7e11c38a595c9e8b8e45a3b45f3cb41c6d6aa
$(PKG)_FILE     := qtbase-everywhere-src-$($(PKG)_VERSION).tar.xz
$(PKG)_SUBDIR   := qtbase-everywhere-src-$($(PKG)_VERSION)
$(PKG)_URL      := https://download.qt.io/official_releases/qt/6.0/$($(PKG)_VERSION)/submodules/$($(PKG)_FILE)
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS     := cc openssl pcre2 fontconfig freetype harfbuzz jpeg libpng zlib zstd sqlite mesa $(BUILD)~$(PKG) $(BUILD)~qt6tools
$(PKG)_DEPS_$(BUILD) :=
$(PKG)_OO_DEPS_$(BUILD) += qt6-conf ninja

define $(PKG)_UPDATE
    $(WGET) -q -O- https://download.qt.io/official_releases/qt/6.0/ | \
    $(SED) -n 's,.*href="\(6\.0\.[^/]*\)/".*,\1,p' | \
    grep -iv -- '-rc' | \
    sort |
    tail -1
endef

define $(PKG)_BUILD
    PKG_CONFIG="${TARGET}-pkg-config" \
    PKG_CONFIG_SYSROOT_DIR="/" \
    PKG_CONFIG_LIBDIR="$(PREFIX)/$(TARGET)/lib/pkgconfig" \
    '$(TARGET)-cmake' -S '$(SOURCE_DIR)' -B '$(BUILD_DIR)' \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX='$(PREFIX)/$(TARGET)/qt6' \
        -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
        -DPKG_CONFIG_EXECUTABLE=$(PREFIX)/bin/$(TARGET)-pkg-config \
        -DQT_HOST_PATH='$(PREFIX)/$(BUILD)/qt6' \
        -DQT_QMAKE_TARGET_MKSPEC=win32-g++ \
        -DQT_QMAKE_DEVICE_OPTIONS='CROSS_COMPILE=$(TARGET)-;PKG_CONFIG=$(TARGET)-pkg-config' \
        -DQT_BUILD_EXAMPLES=OFF \
        -DQT_BUILD_BENCHMARKS=OFF \
        -DQT_BUILD_TESTS=OFF \
        -DQT_BUILD_EXAMPLES_BY_DEFAULT=OFF \
        -DQT_BUILD_TOOLS_BY_DEFAULT=ON \
        -DQT_WILL_BUILD_TOOLS=ON \
        -DQT_BUILD_TOOLS_WHEN_CROSSCOMPILING=ON \
        -DBUILD_WITH_PCH=OFF \
        -DFEATURE_rpath=OFF \
        -DFEATURE_pkg_config=ON \
        -DFEATURE_accessibility=ON \
        -DFEATURE_fontconfig=OFF \
        -DFEATURE_opengl=ON \
        -DFEATURE_opengl_dynamic=ON \
        -DFEATURE_use_gold_linker_alias=OFF \
        -DFEATURE_glib=OFF \
        -DFEATURE_icu=OFF \
        -DFEATURE_directfb=OFF \
        -DFEATURE_dbus=OFF \
        -DFEATURE_sql=ON \
        -DFEATURE_sql_sqlite=ON \
        -DFEATURE_sql_odbc=ON \
        -DFEATURE_sql_mysql=OFF \
        -DFEATURE_pcre2=ON \
        -DFEATURE_libjpeg=ON \
        -DFEATURE_libpng=ON \
        -DFEATURE_style_windows=ON \
        -DFEATURE_style_windowsvista=ON \
        -DINPUT_sqlite=system \
        -DINPUT_libpng=system \
        -DINPUT_libjpeg=system \
        -DINPUT_freetype=system \
        -DINPUT_pcre=system

    cmake --build '$(BUILD_DIR)' -j '$(JOBS)'
    rm -rf '$(PREFIX)/$(TARGET)/qt6'
    cmake --install '$(BUILD_DIR)'

endef

define $(PKG)_BUILD_$(BUILD)
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        -prefix '$(PREFIX)/$(TARGET)/qt6' \
        -static \
        -release \
        -opensource \
        -confirm-license \
        -no-{eventfd,glib,icu,openssl,opengl,dbus} \
        -no-sql-{db2,ibase,mysql,oci,odbc,psql,sqlite} \
        -no-use-gold-linker \
        -nomake examples \
        -nomake tests \
        -make tools

    '$(TARGET)-cmake' --build '$(BUILD_DIR)' -j '$(JOBS)'
    rm -rf '$(PREFIX)/$(TARGET)/qt6'
    '$(TARGET)-cmake' --install '$(BUILD_DIR)'
endef
