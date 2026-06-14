#import <UIKit/UIKit.h>
#define CGRectSetY(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)

short statusBarStyle, screenRoundness, appswitcherRoundness, iPadDockNumIcons, numberOfRecentApps;
BOOL enabled, wantsHomeBarSB, wantsHomeBarLS, wantsReduceRows, wantsRoundedCorners, wantsXButtons;
BOOL wantsCCGrabber, wantsProudLock, wantsHideSBCC, wantsLSShortcuts, wantsBatteryPercent, wantsiPadDock;
BOOL wantsiPadMultitasking, wantsRecentApps, wantsiPadAppSwitcher, wantsDockInApps, wantsDockInSwitcher;
BOOL noBreadCrumbs;

@class BSPlatform;
@class SBHDefaultIconListLayoutProvider;
@class CSQuickActionsView;
@class CSFullscreenNotificationView;
@class SBIconListGridLayoutConfiguration;
@class CCUIHeaderPocketView;
@class CCUIModularControlCenterOverlayViewController;
@class _UIBatteryView;
@class _UIStatusBarStringView;
@class SBReachabilitySettings;
@class _UIStatusBarVisualProvider_iOS;
@class _UIStatusBarVisualProvider_Split828;
@class _UIStatusBarVisualProvider_DynamicSplit;
@class SBFHomeGrabberSettings;
@class CSTeachableMomentsContainerView;
@class MTLumaDodgePillSettings;
@class SBFloatingDockSuggestionsModel;
@class SBAppSwitcherSettings;
@class SBFluidSwitcherViewController;
@class _UIRootWindow;
@class SBReachabilityBackgroundView;
@class SBUIPasscodeBiometricResource;
@class SBDashBoardLockScreenEnvironment;
@class SBFLockScreenDateView;
@class SBUIProudLockIconView;
@class CSCombinedListViewController;
@class SBUIBiometricResource;
@class WGWidgetGroupViewController;
@class SBFloatingDockController;
@class SBDeckSwitcherModifier;
@class SBFloatingDockBehaviorAssertion;
@class SBApplication;
@class SBPlatformController;
@class SBMainWorkspace;
@class SBApplicationInfo;


@interface _UIRootWindow : UIView
- (void)_setContinuousCornerRadius:(double)radius;
@end


@interface SBReachabilityBackgroundView : UIView
- (double)_displayCornerRadius;
@end

%hook BSPlatform
- (NSInteger)homeButtonType {
    return 2;
}
%end

@interface UIScreen (Private)
@property (atomic, assign, readonly) NSUInteger screenSizeCategory;
@end

%hook SBHDefaultIconListLayoutProvider
- (NSUInteger)screenType {
    return UIScreen.mainScreen.screenSizeCategory - 1;
}
%end

@interface CSQuickActionsView : UIView
- (UIEdgeInsets)_buttonOutsets;
@property (nonatomic, retain) UIControl *flashlightButton;
@property (nonatomic, retain) UIControl *cameraButton;
@end

%hook CSQuickActionsView
- (BOOL)_prototypingAllowsButtons {
    return wantsLSShortcuts;
}
- (void)_layoutQuickActionButtons {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat y = screenBounds.size.height - 90 - [self _buttonOutsets].top;
    self.flashlightButton.frame = CGRectMake(46, y, 50, 50);
    self.cameraButton.frame = CGRectMake(screenBounds.size.width - 96, y, 50, 50);
}
%end

@interface CSFullscreenNotificationView : UIView
@end

%hook CSFullscreenNotificationView
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, -44));
}
%end

%hook SBIconListGridLayoutConfiguration
- (NSUInteger)numberOfPortraitRows {
    NSUInteger orig = %orig;
    if (orig < 4) return orig;
    return orig - (wantsReduceRows ? 1 : 0);
}
%end

%group DefaultSBCC
%hook CCUIHeaderPocketView
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, -40));
}
- (void)setCompactScaleTransform:(CGAffineTransform)arg1 {
    return;
}
%end
%end

%group HideSBCC
%hook CCUIModularControlCenterOverlayViewController
- (CCUIHeaderPocketView*)overlayHeaderView {
    return nil;
}
%end
%end

%group batteryPercent
%hook _UIBatteryView
-(BOOL)_currentlyShowsPercentage {
    return YES;
}
-(BOOL)_shouldShowBolt {
    return NO;
}
%end
%hook _UIStatusBarStringView
- (void)setText:(NSString *)text {
    if ([text containsString:@"%"])
        return;
    else
        %orig(text);
}
%end
%end

%hook SBReachabilitySettings
- (void)setSystemWideSwipeDownHeight:(double)systemWideSwipeDownHeight {
    %orig(100);
}
%end

%group defaultStatusBar
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    return NSClassFromString(@"_UIStatusBarVisualProvider_LegacyPhone");
}
%end
%end

%group StatusBarX
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    return NSClassFromString(@"_UIStatusBarVisualProvider_Split828");
}
%end
%hook SBIconListGridLayoutConfiguration
- (UIEdgeInsets)portraitLayoutInsets {
    UIEdgeInsets insets = %orig;
    NSUInteger rows = MSHookIvar<NSUInteger>(self, "_numberOfPortraitRows");
    if (rows < 4) return insets;
    return UIEdgeInsetsMake(insets.top + 10, insets.left, insets.bottom, insets.right);
}
%end
%end

%group StatusBarXSpacing
%hook _UIStatusBarVisualProvider_Split828
+(CGSize)notchSize {
    CGSize orig = %orig;
    return CGSizeMake(orig.width, 18);
}
+(double)height {
    return 20;
}
%end
%end

%group StatusBarDynamicSplit
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    return NSClassFromString(@"_UIStatusBarVisualProvider_DynamicSplit");
}
%end
%end

%hook SBIconListGridLayoutConfiguration
- (UIEdgeInsets)portraitLayoutInsets {
    UIEdgeInsets insets = %orig;
    NSUInteger rows = MSHookIvar<NSUInteger>(self, "_numberOfPortraitRows");
    if (rows < 4) return insets;
    return UIEdgeInsetsMake(insets.top + 10, insets.left, insets.bottom, insets.right);
}
%end


%group StatusBariPad
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    if (wantsRoundedCorners && screenRoundness > 15)
        return NSClassFromString(@"_UIStatusBarVisualProvider_RoundedPad_ForcedCellular");
    return NSClassFromString(@"_UIStatusBarVisualProvider_Pad_ForcedCellular");
}
%end

%hook CCUIHeaderPocketView
- (void)setFrame:(CGRect)frame {
    CGFloat yOffset = (wantsRoundedCorners && screenRoundness > 15) ? -20 : -24;
    %orig(CGRectSetY(frame, yOffset));
}
%end
%end

%hook SBFHomeGrabberSettings
- (BOOL)isEnabled {
    return wantsHomeBarSB;
}
%end

%group hideHomeBarLS
%hook CSTeachableMomentsContainerView
-(void)setHomeAffordanceContainerView:(UIView *)arg1 {
    return;
}
%end
%end

%group completelyRemoveHomeBar
%hook MTLumaDodgePillSettings
- (void)setHeight:(double)arg1 {
    arg1 = 0;
    %orig;
}
%end
%end

%group customNumDockIcons
%hook SBIconListGridLayoutConfiguration
- (NSUInteger)numberOfPortraitColumns {
    NSUInteger rows = MSHookIvar<NSUInteger>(self, "_numberOfPortraitRows");
    if (rows == 1)
        return iPadDockNumIcons;
    return %orig;
}
%end
%end

%group customNumRecentApps
%hook SBFloatingDockSuggestionsModel
-(id)initWithMaximumNumberOfSuggestions:(unsigned long long)arg1 iconController:(id)arg2 recentsController:(id)arg3 recentsDataStore:(id)arg4 recentsDefaults:(id)arg5 floatingDockDefaults:(id)arg6 appSuggestionManager:(id)arg7 analyticsClient:(id)arg8 applicationController:(id)arg9 {
    return %orig(numberOfRecentApps, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
}
%end
%end

%group noRecentApps
%hook SBFloatingDockSuggestionsModel
- (BOOL)_shouldProcessAppSuggestion:(id)arg1 {
    return NO;
}
-(void)_setRecentsEnabled:(BOOL)arg1 {
    %orig(NO);
}
%end
%end

%hook SBFluidSwitcherViewController
- (double)displayCornerRadius {
    return appswitcherRoundness;
}
%end

%group iPadAppSwitcher
%hook SBAppSwitcherSettings
-(void)setSwitcherStyle:(NSInteger)arg1 {
    %orig(2);
}
%end
%end

%group ccGrabber
@interface CSTeachableMomentsContainerView : UIView
@property(retain, nonatomic) UIView *controlCenterGrabberView;
@property(retain, nonatomic) UIView *controlCenterGrabberEffectContainerView;
@property(retain, nonatomic) UIImageView *controlCenterGlyphView;
@end

%hook CSTeachableMomentsContainerView
- (void)_layoutControlCenterGrabberAndGlyph {
    %orig;
    if (statusBarStyle == 2) {
        self.controlCenterGrabberEffectContainerView.frame = CGRectMake(self.frame.size.width - 73, 40, 46, 2.5);
        self.controlCenterGrabberView.frame = CGRectMake(0, 0, 46, 2.5);
        self.controlCenterGlyphView.frame = CGRectMake(315, 50, 16.6, 19.3);
    } else {
        self.controlCenterGrabberEffectContainerView.frame = CGRectMake(self.frame.size.width - 75.5, 24, 60.5, 2.5);
        self.controlCenterGrabberView.frame = CGRectMake(0, 0, 60.5, 2.5);
        self.controlCenterGlyphView.frame = CGRectMake(320, 35, 16.6, 19.3);
    }
}
%end
%end

%group removeBreadcrumbs
%hook _UIStatusBarData
-(void)setBackNavigationEntry:(id)arg1 {
    return;
}
%end
%end

%group originalButtons
%hook SBLockHardwareButtonActions
- (id)initWithHomeButtonType:(long long)arg1 proximitySensorManager:(id)arg2 {
    return %orig(1, arg2);
}
%end
%hook SBHomeHardwareButtonActions
- (id)initWitHomeButtonType:(long long)arg1 {
    return %orig(1);
}
%end

static int applicationDidFinishLaunching = 2;

%hook SBPressGestureRecognizer
- (void)setAllowedPressTypes:(NSArray *)arg1 {
    NSArray *lockHome = @[@104, @101];
    NSArray *lockVol = @[@104, @102, @103];
    if ([arg1 isEqual:lockVol] && applicationDidFinishLaunching == 2) {
        %orig(lockHome);
        applicationDidFinishLaunching--;
        return;
    }
    %orig;
}
%end

%hook SBClickGestureRecognizer
- (void)addShortcutWithPressTypes:(id)arg1 {
    if (applicationDidFinishLaunching == 1) {
        applicationDidFinishLaunching--;
        return;
    }
    %orig;
}
%end

%hook SBHomeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 buttonActions:(id)arg3 gestureRecognizerConfiguration:(id)arg4 {
    return %orig(arg1, 1, arg3, arg4);
}
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 {
    return %orig(arg1, 1);
}
%end
%hook SBLockHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 proximitySensorManager:(id)arg3 homeHardwareButton:(id)arg4 volumeHardwareButton:(id)arg5 buttonActions:(id)arg6 homeButtonType:(long long)arg7 createGestures:(BOOL)arg8 {
    return %orig(arg1, arg2, arg3, arg4, arg5, arg6, 1, arg8);
}
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 proximitySensorManager:(id)arg3 homeHardwareButton:(id)arg4 volumeHardwareButton:(id)arg5 homeButtonType:(long long)arg6 {
    return %orig(arg1, arg2, arg3, arg4, arg5, 1);
}
%end
%hook SBVolumeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 homeButtonType:(long long)arg3 {
    return %orig(arg1, arg2, 1);
}
%end
%end

%group roundedCorners
%hook _UIRootWindow
- (void)_setContinuousCornerRadius:(double)radius {
    %orig(screenRoundness);
}
%end

%hook SBReachabilityBackgroundView
- (double)_displayCornerRadius {
    return screenRoundness;
}
%end
%end

%group ProudLock
%hook SBUIPasscodeBiometricResource
-(BOOL)hasPearlSupport {
    return YES;
}
-(BOOL)hasMesaSupport {
    return NO;
}
%end

@interface SBDashBoardMesaUnlockBehaviorConfiguration : NSObject
- (BOOL)_isAccessibilityRestingUnlockPreferenceEnabled;
@end

@interface SBDashBoardBiometricUnlockController : NSObject
@end

@interface SBLockScreenController : NSObject
+ (id)sharedInstance;
- (BOOL)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2;
@end

CGFloat offset = 0;

%hook SBFLockScreenDateView
-(id)initWithFrame:(CGRect)arg1 {
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    if (screenWidth <= 320) offset = 20;
    else if (screenWidth <= 375) offset = 25;
    return %orig;
}
- (void)layoutSubviews {
    %orig;
    UIView *timeView = MSHookIvar<UIView*>(self, "_timeLabel");
    UIView *dateSubtitleView = MSHookIvar<UIView*>(self, "_dateSubtitleView");
    UIView *customSubtitleView = MSHookIvar<UIView*>(self, "_customSubtitleView");
    timeView.frame = CGRectSetY(timeView.frame, timeView.frame.origin.y + offset);
    dateSubtitleView.frame = CGRectSetY(dateSubtitleView.frame, dateSubtitleView.frame.origin.y + offset);
    customSubtitleView.frame = CGRectSetY(customSubtitleView.frame, customSubtitleView.frame.origin.y + offset);
}
%end

%hook SBDashBoardLockScreenEnvironment
- (void)handleBiometricEvent:(unsigned long long)arg1 {
    %orig;
    if (arg1 == 4) {
        SBDashBoardBiometricUnlockController *controller = MSHookIvar<SBDashBoardBiometricUnlockController*>(self, "_biometricUnlockController");
        SBDashBoardMesaUnlockBehaviorConfiguration *behavior = MSHookIvar<SBDashBoardMesaUnlockBehaviorConfiguration*>(controller, "_biometricUnlockBehaviorConfiguration");
        if ([behavior _isAccessibilityRestingUnlockPreferenceEnabled]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[%c(SBLockScreenManager) sharedInstance] _finishUIUnlockFromSource:12 withOptions:nil];
            });
        }
    }
}
%end

%hook SBUIProudLockIconView
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y + offset * 3));
}
%end

%hook CSCombinedListViewController
- (UIEdgeInsets)_listViewDefaultContentInsets {
    UIEdgeInsets insets = %orig;
    insets.top += offset;
    return insets;
}
%end

%hook SBUIBiometricResource
- (id)init {
    id obj = %orig;
    MSHookIvar<BOOL>(obj, "_hasMesaHardware") = NO;
    MSHookIvar<BOOL>(obj, "_hasPearlHardware") = YES;
    return obj;
}
%end

@interface WGWidgetGroupViewController : UIViewController
@end

%hook WGWidgetGroupViewController
- (void)updateViewConstraints {
    %orig;
    self.view.frame = CGRectSetY(self.view.frame, self.view.frame.origin.y + (offset/2));
}
%end
%end

%group iPadDock
%hook SBFloatingDockController
+ (BOOL)isFloatingDockSupported {
    return YES;
}
%end
%end

%group noDockInAppSwitcher
%hook SBDeckSwitcherModifier
-(BOOL)shouldConfigureInAppDockHiddenAssertion {
    return YES;
}
%end
%end

%group noDockInApps
%hook SBFloatingDockBehaviorAssertion
-(BOOL)gesturePossible {
    return NO;
}
%end
%end

%group iPadMultitasking
%hook SBApplication
- (BOOL)isMedusaCapable {
    return YES;
}
%end
%hook SBPlatformController
-(long long)medusaCapabilities {
    return 2;
}
%end
%hook SBMainWorkspace
-(BOOL)isMedusaEnabled {
    return YES;
}
%end
%hook SBApplicationInfo
-(BOOL)supportsMultiwindow {
    return YES;
}
%end
%end

void loadPrefs() {
    @autoreleasepool {
        NSString *path = @"/var/mobile/Library/Preferences/com.ryannair05.little12.plist";
        NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:path];
        if (prefs) {
            enabled = [[prefs objectForKey:@"enabled"] boolValue];
            statusBarStyle = [[prefs objectForKey:@"statusBarStyle"] integerValue];
            screenRoundness = [[prefs objectForKey:@"screenRoundness"] integerValue];
            appswitcherRoundness = [[prefs objectForKey:@"appswitcherRoundness"] integerValue];
            wantsHomeBarSB = [[prefs objectForKey:@"homeBarSB"] boolValue];
            wantsHomeBarLS = [[prefs objectForKey:@"homeBarLS"] boolValue];
            if ([[prefs objectForKey:@"roundedAppSwitcher"] boolValue] == NO)
                appswitcherRoundness = 0;
            wantsReduceRows = [[prefs objectForKey:@"reduceRows"] boolValue];
            wantsCCGrabber = [[prefs objectForKey:@"ccGrabber"] boolValue];
            wantsBatteryPercent = [[prefs objectForKey:@"batteryPercent"] boolValue];
            wantsiPadDock = [[prefs objectForKey:@"iPadDock"] boolValue];
            wantsiPadMultitasking = wantsiPadDock ? [[prefs objectForKey:@"iPadMultitasking"] boolValue] : NO;
            wantsXButtons = [[prefs objectForKey:@"xButtons"] boolValue];
            wantsDockInApps = [[prefs objectForKey:@"dockInApps"] boolValue];
            wantsDockInSwitcher = [[prefs objectForKey:@"dockInSwitcher"] boolValue];
            wantsRoundedCorners = [[prefs objectForKey:@"roundedCorners"] boolValue];
            iPadDockNumIcons = [[prefs objectForKey:@"numAppsonDock"] integerValue];
            numberOfRecentApps = [[prefs objectForKey:@"numRecAppsonDock"] integerValue];
            wantsRecentApps = [[prefs objectForKey:@"recApponDock"] boolValue];
            wantsProudLock = [[prefs objectForKey:@"ProudLock"] boolValue];
            wantsiPadAppSwitcher = [[prefs objectForKey:@"iPadSwitcher"] boolValue];
            wantsHideSBCC = [[prefs objectForKey:@"HideSBCC"] boolValue];
            wantsLSShortcuts = [[prefs objectForKey:@"lsShortcutsEnabled"] boolValue];
            noBreadCrumbs = [[prefs objectForKey:@"noBreadCrumbs"] boolValue];
        } else {
            NSString *defaultPath = @"/Library/PreferenceBundles/little12prefs.bundle/defaults.plist";
            if ([[NSFileManager defaultManager] fileExistsAtPath:defaultPath]) {
                NSError *error = nil;
                [[NSFileManager defaultManager] copyItemAtPath:defaultPath toPath:path error:&error];
                if (error) {
                    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                } else {
                    loadPrefs();
                }
            }
        }
    }
}

%ctor {
    @autoreleasepool {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.ryannair05.little12prefs/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        loadPrefs();
        
        if (enabled) {
            if (statusBarStyle == 1) %init(StatusBariPad);
            else if (statusBarStyle > 1) {
                if (statusBarStyle == 4) {
                    %init(StatusBarDynamicSplit);
                    
                } else if (statusBarStyle == 3) {
                    %init(StatusBarXSpacing);
                } else { // statusBarStyle == 2
                    %init(StatusBarX);
                }
            } else {
                %init(defaultStatusBar);
            }
            
            if (!wantsHomeBarLS) {
                %init(hideHomeBarLS);
                if (!wantsHomeBarSB) %init(completelyRemoveHomeBar);
            }
            
            if (wantsCCGrabber) %init(ccGrabber);
            if (wantsBatteryPercent) %init(batteryPercent);
            if (!wantsXButtons) %init(originalButtons);
            if (wantsHideSBCC) %init(HideSBCC);
            else if (statusBarStyle == 0) %init(DefaultSBCC);
            if (!wantsDockInSwitcher) %init(noDockInAppSwitcher);
            if (wantsRoundedCorners) %init(roundedCorners);
            
            if (wantsiPadDock) {
                %init(iPadDock);
                if (!wantsRecentApps) %init(noRecentApps);
                if (numberOfRecentApps != 3) %init(customNumRecentApps);
                if (iPadDockNumIcons != 4) %init(customNumDockIcons);
            }
            
            if (wantsiPadMultitasking) %init(iPadMultitasking);
            if (wantsProudLock) %init(ProudLock);
            if (wantsiPadAppSwitcher) %init(iPadAppSwitcher);
            if (!wantsDockInApps) %init(noDockInApps);
            if (noBreadCrumbs) %init(removeBreadcrumbs);
            
            %init;
        }
    }
}