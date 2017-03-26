//
//  AppDelegate.m
//  DotaAsker
//
//  Created by Artem on 07/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

// Local
#import "AppDelegate.h"
#import "Client.h"
#import "Palette.h"

// IOS
#import <Realm/Realm.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self customizeAppearence];
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
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
    [[Palette shared] setThemesButtonColor:[UIColor colorWithRed:0.875 green:0.875 blue:0.875 alpha:1.00]];
    
    // setting up pattern
    [[Palette shared] setPattern:[UIImage imageNamed:@"pattern-6"]];
    
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"icon-back-white.png"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"icon-back-white.png"]];
        
    //customizing NavigationBar
    UINavigationBar *navBarAppearence = [UINavigationBar appearance];
    navBarAppearence.titleTextAttributes =
      @{
        NSForegroundColorAttributeName: [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f],
        NSFontAttributeName : [UIFont fontWithName:@"TrajanBold" size:14.0f]
       };
    navBarAppearence.barTintColor = [[Palette shared] navigationPanelColor];
    navBarAppearence.tintColor = [UIColor whiteColor];
    navBarAppearence.backgroundColor = [[Palette shared] navigationPanelColor];
}

- (void)printAvailableFontNames {
    NSArray *trajanFonts = [UIFont fontNamesForFamilyName:@"Trajan"];
    NSLog(@"Available Trajan font names: %@", trajanFonts);
}

@end
