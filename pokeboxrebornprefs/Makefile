TARGET := iphone:clang:latest:14.5

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PokeboxRebornPrefs

PokeboxRebornPrefs_FILES = $(shell find Sources/PokeboxRebornPrefs -name '*.swift') $(shell find Sources/PokeboxRebornPrefsC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
PokeboxRebornPrefs_SWIFTFLAGS = -ISources/PokeboxRebornPrefsC/include
PokeboxRebornPrefs_INSTALL_PATH = /Library/PreferenceBundles
PokeboxRebornPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
