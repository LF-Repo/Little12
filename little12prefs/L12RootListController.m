#include "L12RootListController.h"
#include <dlfcn.h>

#if __cplusplus
extern "C" {
#endif
    // Private API function pointers
    CFSetRef (*SBSCopyDisplayIdentifiersPtr)();
    NSString* (*SBSCopyLocalizedApplicationNameForDisplayIdentifierPtr)(NSString *identifier);
#if __cplusplus
}
#endif

@interface NSMutableArray(Private)
- (PSSpecifier *)specifierForID:(NSString *)arg1;
@end

OBWelcomeController *welcomeController;

@implementation L12RootListController

@synthesize respringButton;

+ (void)load {
    void *handle = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices", RTLD_LAZY);
    if (handle) {
        SBSCopyDisplayIdentifiersPtr = dlsym(handle, "SBSCopyDisplayIdentifiers");
        SBSCopyLocalizedApplicationNameForDisplayIdentifierPtr = dlsym(handle, "SBSCopyLocalizedApplicationNameForDisplayIdentifier");
    }
}

- (NSString *)bundlePath {
    return [[NSBundle bundleForClass:self.class] resourcePath];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(respring:)];
        self.navigationItem.rightBarButtonItem = self.respringButton;
        self.navigationItem.titleView = [UIView new];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = @"Little12";
        [self.navigationItem.titleView addSubview:self.titleLabel];
    
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        NSString *iconPath = [[self bundlePath] stringByAppendingPathComponent:@"icon@3x.png"];
        self.iconView.image = [UIImage imageWithContentsOfFile:iconPath];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconView.alpha = 0.0;
        [self.navigationItem.titleView addSubview:self.iconView];

        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,200)];
        UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,200,200)];
        headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        NSString *bannerPath = [[self bundlePath] stringByAppendingPathComponent:@"Banner.png"];
        headerImageView.image = [UIImage imageWithContentsOfFile:bannerPath];
        headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.headerView addSubview:headerImageView];
    
        [NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
            [self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
            [headerImageView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor],
            [headerImageView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor],
            [headerImageView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor],
            [headerImageView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
        ]];
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat const offsetY = scrollView.contentOffset.y;
    if (offsetY > 500) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.0;
            self.titleLabel.alpha = 1.0;
        }];
    }
}

- (NSArray *)specifiers {
    if (_specifiers == nil) {
        NSMutableArray *testingSpecs = [[self loadSpecifiersFromPlistName:@"Root" target:self] mutableCopy];
        [testingSpecs addObjectsFromArray:[self appSpecifiers]];
        _specifiers = testingSpecs;
        self.savedSpecifiers = [[NSMutableDictionary alloc] init];
        for (PSSpecifier *specifier in [self specifiers]) {
            if ([specifier propertyForKey:@"id"]) {
                [self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
            }
        }

        NSDictionary const *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryannair05.little12.plist"];
        BOOL firstTime = !prefs[@"firstTime"] ? YES : [prefs[@"firstTime"] boolValue];
            
        if (firstTime && NSClassFromString(@"OBWelcomeController")) {
            UIImage *gearIcon = nil;
            if (@available(iOS 13.0, *)) {
                gearIcon = [UIImage systemImageNamed:@"gear"];
            } else {
                gearIcon = [UIImage imageNamed:@"gear.png"];
            }
            welcomeController = [[OBWelcomeController alloc] initWithTitle:@"Welcome to Little12" detailText:@"Little12 Brings iPhone 12 Gestures and Features to all devices!" icon:gearIcon];
            
            NSArray *titles = @[@"The Tweak", @"App Support", @"Support", @"Open Source"];
            NSArray *descriptions = @[
                @"The iPhone X Gestures should be available on all devices, and so Little12 brings these fluid gestures to your device.",
                @"The majority of apps work with Little12 without an issue. For the exceptions, I'm doing my best to fix them though sometimes it can prove to be a challenge. Turning on or off the compatibility mode and/or device spoofing settings may improve or worsen certain apps.",
                @"Little12 is made to be the best possible, but there are still some issues unfortunately. To report issues and for support I can be contacted over Email, Discord, Twitter, Reddit, and Github.",
                @"Little12 is open source and can be found on Github. Feel free to check out the code anytime and even make a pull request."
            ];
            NSArray *imageNames = @[@"1.circle.fill", @"2.circle.fill", @"3.circle.fill", @"4.circle.fill"];
            for (NSInteger i = 0; i < titles.count; i++) {
                UIImage *img = nil;
                if (@available(iOS 13.0, *)) {
                    img = [UIImage systemImageNamed:imageNames[i]];
                } else {
                    img = [UIImage imageNamed:[imageNames[i] stringByReplacingOccurrencesOfString:@"." withString:@"_"]];
                }
                [welcomeController addBulletedListItemWithTitle:titles[i] description:descriptions[i] image:img];
            }

            OBBoldTrayButton* continueButton = [OBBoldTrayButton buttonWithType:1];
            [continueButton addTarget:self action:@selector(dismissWelcomeController) forControlEvents:UIControlEventTouchUpInside];
            [continueButton setTitle:@"Continue" forState:UIControlStateNormal];
            [continueButton setClipsToBounds:YES];
            [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
            [continueButton.layer setCornerRadius:19]; 
            [welcomeController.buttonTray addButton:continueButton];
            
            if (@available(iOS 13.0, *)) {
                welcomeController.buttonTray.effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
                UIVisualEffectView *effectWelcomeView = [[UIVisualEffectView alloc] initWithFrame:welcomeController.viewIfLoaded.bounds];
                effectWelcomeView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
                [welcomeController.viewIfLoaded insertSubview:effectWelcomeView atIndex:0];
            } else {
                welcomeController.buttonTray.effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                UIVisualEffectView *effectWelcomeView = [[UIVisualEffectView alloc] initWithFrame:welcomeController.viewIfLoaded.bounds];
                effectWelcomeView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                [welcomeController.viewIfLoaded insertSubview:effectWelcomeView atIndex:0];
            }
            welcomeController.viewIfLoaded.backgroundColor = [UIColor clearColor];
            [welcomeController.buttonTray addCaptionText:@"Thank you for your using Little12!"];
            welcomeController.modalPresentationStyle = UIModalPresentationPageSheet;
            if (@available(iOS 13.0, *)) {
                welcomeController.modalInPresentation = YES;
            }
            welcomeController.view.tintColor = [UIColor systemBlueColor];
            [self presentViewController:welcomeController animated:YES completion:nil];
        }
    }
    return _specifiers;
}

-(void)dismissWelcomeController { 
    [welcomeController dismissViewControllerAnimated:YES completion:nil];
    NSMutableDictionary const *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryannair05.little12.plist"];
    [prefs setValue:[NSNumber numberWithBool:NO] forKey:@"firstTime"]; 
    [prefs writeToFile:@"/var/mobile/Library/Preferences/com.ryannair05.little12.plist" atomically:YES]; 
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]] setOnTintColor:[UIColor colorWithRed:0.00 green:0.51 blue:1.00 alpha:1.00]];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[self.class]] setTintColor:[UIColor colorWithRed:0.00 green:0.51 blue:1.00 alpha:1.00]];
}    

-(void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryannair05.little12.plist"];
    BOOL hasStatusBarOrInset = NO;
    
    if (([[prefs objectForKey:@"iPadDock"] boolValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"iPadMultitasking"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"iPadDockNumIcons"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"numAppsonDock"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"numRecAppsonDock"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"dockInApps"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"dockInSwitcher"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"recApponDock"]] animated:NO];
    }
    else if (([[prefs objectForKey:@"recApponDock"] boolValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"numRecAppsonDock"]] animated:NO];
    }

    if  (([[prefs objectForKey:@"statusBarStyle"] integerValue]) > 1) {
        hasStatusBarOrInset = YES;
    }
    else if (([[prefs objectForKey:@"bottomInset"] boolValue]) == 1) {
        hasStatusBarOrInset = YES;
    }

    if (([[prefs objectForKey:@"roundedAppSwitcher"] boolValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"appswitcherRoundness"]] animated:YES];
    }

    if (([[prefs objectForKey:@"roundedCorners"] boolValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"screenRoundness"]] animated:YES];
    }

    if (!hasStatusBarOrInset){
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"compatabilityMode"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"deviceSpoofing"]] animated:YES];
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/KeyboardPlus.dylib"]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"keyboardDock"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"keyboardSpacing"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"noGesturesForKeyboard"]] animated:YES];
    }
    else if (([[prefs objectForKey:@"keyboardDock"] boolValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"keyboardSpacing"]] animated:NO];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.tableHeaderView = self.headerView;
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

-(void)reloadSpecifiers {
    [super reloadSpecifiers];
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryannair05.little12.plist"];
    BOOL hasStatusBarOrInset = NO;
    
    if (([[prefs objectForKey:@"iPadDock"] boolValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"iPadMultitasking"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"iPadDockNumIcons"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"numAppsonDock"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"numRecAppsonDock"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"dockInApps"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"dockInSwitcher"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"recApponDock"]] animated:NO];
    }
    else if (([[prefs objectForKey:@"recApponDock"] boolValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"numRecAppsonDock"]] animated:NO];
    }

    if  (([[prefs objectForKey:@"statusBarStyle"] integerValue]) > 1) {
        hasStatusBarOrInset = YES;
    }
    else if (([[prefs objectForKey:@"bottomInset"] boolValue]) == 1) {
        hasStatusBarOrInset = YES;
    }

    if (([[prefs objectForKey:@"roundedAppSwitcher"] boolValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"appswitcherRoundness"]] animated:NO];
    }

    if (([[prefs objectForKey:@"roundedCorners"] boolValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"screenRoundness"]] animated:NO];
    }

    if (!hasStatusBarOrInset){
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"compatabilityMode"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"deviceSpoofing"]] animated:NO];
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/KeyboardPlus.dylib"]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"keyboardDock"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"keyboardSpacing"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"noGesturesForKeyboard"]] animated:NO];
    }
    else if (([[prefs objectForKey:@"keyboardDock"] boolValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"keyboardSpacing"]] animated:NO];
    }
}

-(NSMutableArray*)appSpecifiers {
    NSMutableArray *specifiers = [NSMutableArray array];
    if (!SBSCopyDisplayIdentifiersPtr || !SBSCopyLocalizedApplicationNameForDisplayIdentifierPtr) {
        return specifiers;
    }
    NSArray *displayIdentifiers = [(__bridge NSSet *)SBSCopyDisplayIdentifiersPtr() allObjects];
    NSMutableDictionary *apps = [NSMutableDictionary new];
    for (NSString *appIdentifier in displayIdentifiers) {
        NSString *appName = SBSCopyLocalizedApplicationNameForDisplayIdentifierPtr(appIdentifier);
        if (appName) {
            [apps setObject:appName forKey:appIdentifier];
        }
    }
    OrderedDictionary *dataSourceUser = (OrderedDictionary*)[apps copy];
    dataSourceUser = [self trimDataSource:dataSourceUser];
    dataSourceUser = [self sortedDictionary:dataSourceUser];
    
    PSSpecifier* groupSpecifier = [PSSpecifier groupSpecifierWithName:@"Per-app Customization:"];
    [specifiers addObject:groupSpecifier];
    
    for (NSString *bundleIdentifier in dataSourceUser.allKeys) {
        NSString *displayName = dataSourceUser[bundleIdentifier];
        PSSpecifier *spe = [PSSpecifier preferenceSpecifierNamed:displayName target:self set:nil get:@selector(getIsWidgetSetForSpecifier:) detail:[L12AppSettingsController class] cell:PSLinkListCell edit:nil];
        [spe setProperty:@"IBKWidgetSettingsController" forKey:@"detail"];
        [spe setProperty:@YES forKey:@"isController"];
        [spe setProperty:@YES forKey:@"enabled"];
        [spe setProperty:bundleIdentifier forKey:@"bundleIdentifier"];
        [spe setProperty:bundleIdentifier forKey:@"appIDForLazyIcon"];
        [spe setProperty:@YES forKey:@"useLazyIcons"];
        [specifiers addObject:spe];
    }
    return specifiers;
}

-(OrderedDictionary*)trimDataSource:(OrderedDictionary*)dataSource {
    OrderedDictionary *mutable = [dataSource mutableCopy];
    NSArray *bannedIdentifiers = [[NSArray alloc] initWithObjects:@"com.apple.sidecar", nil];
    for (NSString *key in bannedIdentifiers) {
        [mutable removeObjectForKey:key];
    }
    return mutable;
}

-(OrderedDictionary*)sortedDictionary:(OrderedDictionary*)dict {
    NSArray *sortedValues;
    OrderedDictionary *mutable = [OrderedDictionary dictionary];
    sortedValues = [[dict allValues] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString *value in sortedValues) {
        NSString const *key = [[dict allKeysForObject:value] objectAtIndex:0];
        [mutable setObject:value forKey:key];
    }
    return mutable;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    return ([settings objectForKey:specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    [settings setObject:value forKey:specifier.properties[@"key"]];
    [settings writeToFile:path atomically:YES];
    CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    if (notificationName) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
    }

    NSString const *key = [specifier propertyForKey:@"key"];
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryannair05.little12.plist"];

    if ([key isEqualToString:@"iPadDock"]) {
        if ([value boolValue] == false) {
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"iPadMultitasking"]] animated:YES];
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"iPadDockNumIcons"]] animated:YES];
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"numAppsonDock"]] animated:YES];
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"recApponDock"]] animated:YES];
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"numRecAppsonDock"]] animated:YES];
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"dockInApps"]] animated:YES];
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"dockInSwitcher"]] animated:NO];
        }
        else {
            if (![self containsSpecifier:self.savedSpecifiers[@"iPadMultitasking"]]) {
                if (![self containsSpecifier:self.savedSpecifiers[@"iPadDockNumIcons"]]) {
                    [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"iPadDockNumIcons"]] afterSpecifierID:@"iPadSwitcher" animated:YES];
                    [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"numAppsonDock"]] afterSpecifierID:@"iPadDockNumIcons" animated:YES];
                    [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"recApponDock"]] afterSpecifierID:@"numAppsonDock" animated:YES];
                    [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"dockInApps"]] afterSpecifierID:@"recApponDock" animated:YES];
                    [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"dockInSwitcher"]] afterSpecifierID:@"dockInApps" animated:YES];
                }
                if ([[prefs objectForKey:@"recApponDock"] boolValue]) {
                    [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"numRecAppsonDock"]] afterSpecifierID:@"recApponDock" animated:YES];
                }
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"iPadMultitasking"]] afterSpecifierID:@"dockInSwitcher" animated:YES];
            }
        }
    }
    else if ([key isEqualToString:@"recApponDock"]) {
        if ([value boolValue] == false) {
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"numRecAppsonDock"]] animated:YES];
        }
        else if (![self containsSpecifier:self.savedSpecifiers[@"numRecAppsonDock"]]) {
            [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"numRecAppsonDock"]] afterSpecifierID:@"recApponDock" animated:YES];
        }
    }
    else if ([key isEqualToString:@"keyboardDock"]) {
        if ([value boolValue] == false) {
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"keyboardSpacing"]] animated:YES];
        }
        else if (![self containsSpecifier:self.savedSpecifiers[@"keyboardSpacing"]]) {
            [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"keyboardSpacing"]] afterSpecifierID:@"keyboardDock" animated:YES];
        }
    }
    else if ([key isEqualToString:@"roundedAppSwitcher"]) {
        if ([value boolValue] == false) {
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"appswitcherRoundness"]] animated:YES];
        }
        else if (![self containsSpecifier:self.savedSpecifiers[@"appswitcherRoundness"]]) {
            if ([self containsSpecifier:self.savedSpecifiers[@"roundedAppSwitcher"]])
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"appswitcherRoundness"]] afterSpecifierID:@"roundedAppSwitcher" animated:YES];
            else
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"appswitcherRoundness"]] afterSpecifierID:@"roundedAppSwitcherNoDock" animated:YES];
        }
    }
    else if ([key isEqualToString:@"roundedCorners"]) {
        if ([value boolValue] == false) {
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"screenRoundness"]] animated:YES];
        }
        else if (![self containsSpecifier:self.savedSpecifiers[@"screenRoundness"]]) {
            [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"screenRoundness"]] afterSpecifierID:@"roundedCorners" animated:YES];
        }
    }
    
    if (([[prefs objectForKey:@"statusBarStyle"] integerValue] > 1) || [[prefs objectForKey:@"bottomInset"] boolValue]) {
        if (![self containsSpecifier:self.savedSpecifiers[@"compatabilityMode"]]) {
            if ([self containsSpecifier:self.savedSpecifiers[@"screenRoundness"]])
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"compatabilityMode"]] afterSpecifierID:@"screenRoundness" animated:YES];
            else 
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"compatabilityMode"]] afterSpecifierID:@"roundedCorners" animated:YES];
            [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"deviceSpoofing"]] afterSpecifierID:@"compatabilityMode" animated:YES];
        }
    }
    else {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"compatabilityMode"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"deviceSpoofing"]] animated:YES];
    }
} 

- (void)respring:(id)sender {

    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
    blurView.frame = self.view.bounds;
    blurView.alpha = 0.0;
    [self.view addSubview:blurView];
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        blurView.alpha = 1.0;
    } completion:^(BOOL finished) {

        const char *sbreload_path = NULL;
        if (access("/usr/bin/sbreload", X_OK) == 0) {
            sbreload_path = "/usr/bin/sbreload";
        } else if (access("/var/jb/usr/bin/sbreload", X_OK) == 0) {
            sbreload_path = "/var/jb/usr/bin/sbreload";
        }
        
        pid_t pid;
        int status;
        
        if (sbreload_path) {
            const char* args[] = {sbreload_path, NULL};
            posix_spawn(&pid, sbreload_path, NULL, NULL, (char* const*)args, NULL);
            waitpid(pid, &status, 0);
        } else {


            const char* args[] = {"killall", "SpringBoard", NULL};
            posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
            waitpid(pid, &status, 0);
        }
    }];
}
@end

@implementation L12TwitterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 38, 38)];
        self.detailTextLabel.numberOfLines = 1;
        self.detailTextLabel.textColor = [UIColor grayColor];
        self.textLabel.textColor = [UIColor blackColor];
        if (@available(iOS 13.0, *)) {
            self.tintColor = [UIColor labelColor];
        } else {
            self.tintColor = [UIColor blackColor];
        }

        CGFloat const size = 29.f;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, [UIScreen mainScreen].scale);
        specifier.properties[@"iconImage"] = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        _avatarView = [[UIView alloc] initWithFrame:self.imageView.bounds];
        _avatarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _avatarView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1];
        _avatarView.userInteractionEnabled = NO;
        _avatarView.clipsToBounds = YES;
        _avatarView.layer.cornerRadius = size / 2;
        _avatarView.layer.borderWidth = 2;
        if (@available(iOS 13.0, *)) {
            _avatarView.layer.borderColor = [[UIColor tertiaryLabelColor] CGColor];
        } else {
            _avatarView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        }
        [self.imageView addSubview:_avatarView];

        _avatarImageView = [[UIImageView alloc] initWithFrame:_avatarView.bounds];
        _avatarImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _avatarImageView.alpha = 0;
        _avatarImageView.layer.minificationFilter = kCAFilterTrilinear;
        [_avatarView addSubview:_avatarImageView];

        _user = [specifier.properties[@"accountName"] copy];
        NSAssert(_user, @"User name not provided");
        specifier.properties[@"url"] = [self.class _urlForUsername:_user];
        self.detailTextLabel.text = _user;
        if (!_user) return self;

        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://pbs.twimg.com/profile_images/1161080936836018176/4GUKuGlb_200x200.jpg"]];
            NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data && !error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.avatarImage = [UIImage imageWithData:data];
                    });
                }
            }];
            [task resume];
        });
    }
    return self;
}

- (void)setAvatarImage:(UIImage *)avatarImage {
    _avatarImageView.image = avatarImage;
    if (_avatarImageView.alpha == 0) {
        [UIView animateWithDuration:0.15 animations:^{
            _avatarImageView.alpha = 1;
        }];
    }
}

+ (NSURL *)_urlForUsername:(NSString *)user {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) {
        return [NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) {
        return [NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings://"]]) {
        return [NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]];
    } else {
        return [NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]];
    }
}

- (void)setSelected:(BOOL)arg1 animated:(BOOL)arg2 {
    if (arg1) [[UIApplication sharedApplication] openURL:[self.class _urlForUsername:_user] options:@{} completionHandler:nil];
}
@end

@implementation UIColor (libappearancecell)
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
@end

@implementation L12AppearanceTypeStackView

- (L12AppearanceTypeStackView *)initWithType:(int)type forController:(L12AppearanceSelectionTableCell *)controller withImage:(UIImage *)image andText:(NSString *)text andSpecifier:(PSSpecifier *)specifier {
    self = [super init];
    if (self) {
        self.type = type;
        self.hostController = controller;
        self.key = specifier.properties[@"key"];
        self.postNotification = specifier.properties[@"PostNotification"];
        self.tintColor = specifier.properties[@"tintColor"];
        self.feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [self.feedbackGenerator prepare];
        
        self.axis = UILayoutConstraintAxisVertical;
        self.alignment = UIStackViewAlignmentCenter;
        self.distribution = UIStackViewDistributionEqualSpacing;
        self.spacing = 8;
        self.translatesAutoresizingMaskIntoConstraints = false;

        self.iconView = [[UIImageView alloc] init];
        self.iconView.clipsToBounds = YES;
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconView.translatesAutoresizingMaskIntoConstraints = false;
        self.iconView.image = image;
        [self addArrangedSubview:self.iconView];
        [self.iconView.widthAnchor constraintEqualToConstant:60].active = true;

        self.captionLabel = [[UILabel alloc] init];
        self.captionLabel.text = text;
        [self.captionLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [self.captionLabel.heightAnchor constraintEqualToConstant:20].active = true;
        [self addArrangedSubview:self.captionLabel];
        if (@available(iOS 13.0, *)) {
            [self.captionLabel setTextColor:[UIColor labelColor]];
        } else {
            [self.captionLabel setTextColor:[UIColor darkTextColor]];
        }

        self.checkmarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.checkmarkButton.translatesAutoresizingMaskIntoConstraints = false;
        
        NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
        NSMutableDictionary *settings = [NSMutableDictionary dictionary];
        [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
        self.checkmarkButton.selected = [[settings objectForKey:specifier.properties[@"key"]] ?: specifier.properties[@"default"] intValue] == self.type;
        self.checkmarkButton.tintColor = (self.checkmarkButton.selected) ? (self.tintColor ? [UIColor colorFromHexString:self.tintColor] : [UIColor systemBlueColor]) : [UIColor systemGrayColor];
        [self.checkmarkButton.heightAnchor constraintEqualToConstant:22].active = true;
        [self.checkmarkButton.widthAnchor constraintEqualToConstant:22].active = true;
        
        UIImage *normalImage, *selectedImage;
        if (@available(iOS 13.0, *)) {
            normalImage = [UIImage systemImageNamed:@"circle"];
            selectedImage = [UIImage systemImageNamed:@"checkmark.circle.fill"];
        } else {
            normalImage = [UIImage imageNamed:@"circle.png"];
            selectedImage = [UIImage imageNamed:@"checkmark_circle_fill.png"];
        }
        [self.checkmarkButton setImage:normalImage forState:UIControlStateNormal];
        [self.checkmarkButton setImage:selectedImage forState:UIControlStateSelected];
        [self.checkmarkButton addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addArrangedSubview:self.checkmarkButton];

        self.tapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTapped:)];
        self.tapGestureRecognizer.minimumPressDuration = 0;
        [self setUserInteractionEnabled:true];
        [self addGestureRecognizer:self.tapGestureRecognizer];
    }
    return self;
}

- (void)buttonTapped:(UILongPressGestureRecognizer *)sender {
    if(sender.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alpha = 0.5;
        } completion:^(BOOL finished) {}];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alpha = 1;
            [self.hostController updateForType:self.type];
        } completion:^(BOOL finished) {}];
        [self.feedbackGenerator impactOccurred];
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryannair05.little12.plist"];
        [prefs setValue:[NSNumber numberWithInt:self.type] forKey:self.key]; 
        [prefs writeToFile:@"/var/mobile/Library/Preferences/com.ryannair05.little12.plist" atomically:YES]; 
        if(self.postNotification) {
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)self.postNotification, NULL, NULL, true);
        }
    }
}
@end

@implementation L12AppearanceSelectionTableCell

- (L12AppearanceSelectionTableCell *)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
    if (self) {
        NSBundle *prefsBundle = [NSBundle bundleForClass:[specifier.target class]];
        self.options = specifier.properties[@"options"];
        self.containerStackView = [[UIStackView alloc] init];
        self.containerStackView.axis = UILayoutConstraintAxisHorizontal;
        self.containerStackView.alignment = UIStackViewAlignmentCenter;
        self.containerStackView.distribution = UIStackViewDistributionEqualSpacing;
        self.containerStackView.spacing = 60;
        self.containerStackView.translatesAutoresizingMaskIntoConstraints = false;
        for (NSDictionary *option in self.options) {
            L12AppearanceTypeStackView *stackView = [[L12AppearanceTypeStackView alloc] initWithType:[self.options indexOfObject:option] 
                                                                                  forController:self 
                                                                                  withImage:[UIImage imageNamed:option[@"image"] inBundle:prefsBundle compatibleWithTraitCollection:NULL]
                                                                                  andText:option[@"text"]
                                                                                  andSpecifier:specifier];
            [self.containerStackView addArrangedSubview:stackView];
            [stackView.topAnchor constraintEqualToAnchor:self.containerStackView.topAnchor constant:16].active = true;
            [stackView.bottomAnchor constraintEqualToAnchor:self.containerStackView.bottomAnchor constant:-16].active = true;
        }
        [self.contentView addSubview:self.containerStackView];
        [self.containerStackView.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = true;
        [self.containerStackView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = true;
        [self.containerStackView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = true;
    }
    return self;
}

- (L12AppearanceSelectionTableCell *)initWithSpecifier:(PSSpecifier *)specifier {
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"L12AppearanceSelectionTableCell" specifier:specifier];
    return self;
}

- (void)updateForType:(int)type {
    for (L12AppearanceTypeStackView *subview in self.containerStackView.arrangedSubviews) {
        subview.checkmarkButton.selected = subview.type == type;
        subview.checkmarkButton.tintColor = (subview.checkmarkButton.selected) ? (subview.tintColor ? [UIColor colorFromHexString:subview.tintColor] : [UIColor systemBlueColor]) : [UIColor systemGrayColor];
    }
}
@end