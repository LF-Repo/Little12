FINALPACKAGE = 1

export TARGET = iphone:clang:16.5
export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc
export THEOS_PACKAGE_SCHEME = rootless


include /var/theos/makefiles/common.mk

TWEAK_NAME = Little12SpringBoard Little12UIKit

Little12SpringBoard_FILES = TweakSpring.xm
Little12SpringBoard_USE_SUBSTRATE = 1

Little12UIKit_FILES = TweakUI.xm
Little12UIKit_USE_SUBSTRATE = 1


Little12SpringBoard_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
Little12UIKit_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

ARCHS = arm64 arm64e

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += little12prefs
include $(THEOS_MAKE_PATH)/aggregate.mk