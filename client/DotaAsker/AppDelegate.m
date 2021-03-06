//
//  AppDelegate.m
//  DotaAsker
//
//  Created by Artem on 07/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

// Local
#import "AppDelegate.h"
#import "Palette.h"
#import "Helper.h"
#import "ModalLoadingView.h"
#import "Match.h"

// IOS
#import <Realm/Realm.h>

// Libraries
@import FirebaseAnalytics;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self customizeAppearence];
    [FIRApp configure];
    [self migrateIfNeeded];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)customizeAppearence {
    // setting up palette
    [[Palette shared] setBackgroundColor:[UIColor colorWithRed:0.376 green:0.490 blue:0.545 alpha:1.0]];
    [[Palette shared] setStatusBarColor:[UIColor colorWithRed:0.149 green:0.196 blue:0.220 alpha:1.0]];
    [[Palette shared] setNavigationPanelColor:[UIColor colorWithRed:0.216 green:0.278 blue:0.310 alpha:1.00]];
    [[Palette shared] setThemesButtonColor:[UIColor colorWithRed:0.96 green:0.50 blue:0.09 alpha:1.0]];
    [[Palette shared] setDarkGreenColor:[UIColor colorWithRed:0.30 green:0.69 blue:0.31 alpha:1.0]];
    [[Palette shared] setDarkRedColor:[UIColor colorWithRed:0.96 green:0.26 blue:0.21 alpha:1.0]];
    
    // setting up pattern
    [[Palette shared] setPattern:[UIImage imageNamed:@"pattern-1.png"]];
    
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"icon-back-white.png"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"icon-back-white.png"]];
        
    //customizing NavigationBar
    UINavigationBar *navBarAppearence = [UINavigationBar appearance];
    navBarAppearence.titleTextAttributes =
      @{
        NSForegroundColorAttributeName: [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f],
        NSFontAttributeName : [UIFont fontWithName:@"Trajan Pro 3" size:14.0f]
       };
    navBarAppearence.barTintColor = [[Palette shared] navigationPanelColor];
    navBarAppearence.tintColor = [UIColor whiteColor];
    navBarAppearence.backgroundColor = [[Palette shared] navigationPanelColor];
}

- (void)migrateIfNeeded {
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    
    // [1] Match.hidden property added
    config.schemaVersion = 1;
    
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
    // We haven’t migrated anything yet, so oldSchemaVersion == 0
    if (oldSchemaVersion < 1) {
        // The enumerateObjects:block: method iterates
        // over every 'Match' object stored in the Realm file
        [migration enumerateObjects:Match.className
                            block:^(RLMObject *oldObject, RLMObject *newObject) {
        newObject[@"hidden"] = @NO;
        }];
    }
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];
}

- (void)printAvailableFontNames {
    NSArray *trajanFonts = [UIFont fontNamesForFamilyName:@"Trajan Pro 3"];
    NSLog(@"Available Trajan font names: %@", trajanFonts);
}

@end
