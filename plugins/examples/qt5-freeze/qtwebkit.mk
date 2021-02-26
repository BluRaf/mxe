# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := qtwebkit
$(PKG)_WEBSITE  := https://github.com/qtwebkit/qtwebkit
$(PKG)_DESCR    := QtWebKit
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 00698c5
$(PKG)_CHECKSUM := 93cf4dc769cad351d68b6ad625445022bab9987113610843245978cd4bd0cf64
$(PKG)_PATCHES  := $(realpath $(sort $(wildcard $(dir $(lastword $(MAKEFILE_LIST)))/$(PKG)-[0-9]*.patch)))
$(PKG)_GH_CONF  := qtwebkit/qtwebkit/branches/qtwebkit-dev-wip
#$(PKG)_URL      := https://github.com/qtwebkit/qtwebkit/archive/qtwebkit-dev-wip.zip
$(PKG)_DEPS     := cc libxml2 libxslt libwebp qtbase qtquickcontrols \
                   qtsensors qtwebchannel sqlite libtasn1 woff2 gstreamer \
                   gst-libav gst-plugins-bad gst-plugins-good gst-plugins-base gst-plugins-ugly

define $(PKG)_BUILD_SHARED
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DCMAKE_INSTALL_PREFIX=$(PREFIX)/$(TARGET)/qt5 \
        -DCMAKE_CXX_FLAGS='-fpermissive' \
        -DEGPF_DEPS='Qt5Core Qt5Gui Qt5Multimedia Qt5Widgets Qt5WebKit' \
        -DPORT=Qt \
        -DENABLE_GEOLOCATION=OFF \
        -DENABLE_MEDIA_SOURCE=ON \
        -DENABLE_VIDEO=ON \
        -DENABLE_WEB_AUDIO=ON \
        -DENABLE_JIT=OFF \
        -DENABLE_API_TEST=ON \
        -DENABLE_WTF_MULTIPLE_THREADS=OFF \
        -DENABLE_JSC_MULTIPLE_THREADS=OFF \
        -DUSE_GSTREAMER=ON \
        -DUSE_GSTREAMER_DEFAULT=ON \
        -DUSE_GSTREAMER_MPEGTS=ON \
        -DUSE_GSTREAMER_GL=ON \
        -DUSE_MEDIA_FOUNDATION=OFF \
        -DUSE_QT_MULTIMEDIA=OFF
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1 || $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # build test manually
    # add $(BUILD_TYPE_SUFFIX) for debug builds - see qtbase.mk
    $(TARGET)-g++ \
        -W -Wall -std=c++11 \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `$(TARGET)-pkg-config Qt5WebKitWidgets --cflags --libs`

    # batch file to run test programs
    (printf 'set PATH=..\\lib;..\\qt5\\bin;..\\qt5\\lib;%%PATH%%\r\n'; \
     printf 'set QT_QPA_PLATFORM_PLUGIN_PATH=..\\qt5\\plugins\r\n'; \
     printf 'test-$(PKG).exe\r\n'; \
     printf 'cmd\r\n';) \
     > '$(PREFIX)/$(TARGET)/bin/test-$(PKG).bat'
endef
