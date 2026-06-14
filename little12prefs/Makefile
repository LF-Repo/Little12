include /var/theos/makefiles/common.mk

ARCHS = arm64

THEOS_PACKAGE_SCHEME = rootless

BUNDLE_NAME = little12prefs
little12prefs_FILES = L12RootListController.m L12AppSettingsController.m OrderedDictionary.m

little12prefs_PRIVATE_FRAMEWORKS = Preferences SpringBoardServices OnBoardingKit


little12prefs_INSTALL_PATH = /Library/PreferenceBundles

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/little12.plist$(ECHO_END)
