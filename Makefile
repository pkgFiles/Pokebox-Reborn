TARGET := iphone:clang:latest:14.5
INSTALL_TARGET_PROCESSES = SpringBoard
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PokeboxReborn

PokeboxReborn_FILES = $(shell find Sources/PokeboxReborn -name '*.swift') $(shell find Sources/PokeboxRebornC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
PokeboxReborn_SWIFTFLAGS = -ISources/PokeboxRebornC/include
PokeboxReborn_CFLAGS = -fobjc-arc -ISources/PokeboxRebornC/include
PokeboxReborn_EXTRA_FRAMEWORKS = UserNotificationsUIKit SpringBoard

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += pokeboxrebornprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
