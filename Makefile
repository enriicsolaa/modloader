TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = YouTube


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = modloader

modloader_FILES = Tweak.x
modloader_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
