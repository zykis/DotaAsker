//
//  AppDelegate.m
//  DotaAsker
//
//  Created by Artem on 07/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "AppDelegate.h"
#import "DotaButton.h"
#import "Client.h"
#import "EPPZReachability.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self customizeAppearence];
    [EPPZReachability listenHost:SERVER_IP withPort:SERVER_PORT delegate:(id)self];
//    if (![[Client instance] connected]) {
//        [[Client instance] connect];
//    }
//    [[Database instance] loadQuestions];
//    [[Client instance] sendMessageSynchronizeQuestions];
    
    return YES;
}

-(void)reachabilityChanged:(EPPZReachability*) reachability
{
    if ([reachability reachable]) {
//        NSLog(@"Server is reachable");
    }
    else {
//        NSLog(@"Server is unreacable");
    }
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
    //customizing NavigationBar
    UINavigationBar *navBarAppearence = [UINavigationBar appearance];
    [navBarAppearence setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    navBarAppearence.shadowImage = [UIImage new];
    navBarAppearence.translucent = YES;
    navBarAppearence.titleTextAttributes =
      @{
        NSForegroundColorAttributeName: [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f],
        NSFontAttributeName : [UIFont fontWithName:@"TrajanBold" size:14.0f]
       };
    //customizing Dota button
    UIImage *resizeableDotaButton = [[UIImage imageNamed:@"ui_button_dota.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 12, 15, 12)];
    [[DotaButton appearance] setBackgroundImage:resizeableDotaButton forState:UIControlStateNormal];
}

- (void)printAvailableFontNames {
    NSArray *trajanFonts = [UIFont fontNamesForFamilyName:@"Trajan"];
    NSLog(@"Available Trajan font names: %@", trajanFonts);
}

@end
