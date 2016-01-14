//
//  UIViewController+BackgroundImage.m
//  DotaAsker
//
//  Created by Artem on 19/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "UIViewController+Utils.h"
#import "Player.h"

@implementation UIViewController (BackgroundImage)

- (void)loadBackgroundImage: (UIImage*)backgroundImage {
    UIGraphicsBeginImageContext(self.view.frame.size);
    [backgroundImage drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

+(UIViewController*) findBestViewController:(UIViewController*)vc {
    
    if (vc.presentedViewController) {
        
        // Return presented view controller
        return [UIViewController findBestViewController:vc.presentedViewController];
        
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
        
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.topViewController];
        else
            return vc;
        
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
        
    }
    
}

+(UIViewController*) currentViewController {
    // Find best view controller
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [UIViewController findBestViewController:viewController];
}

//+ (void)presentLoadingViewAndCompleteWith:(void (^)(void))aBlock {
//    UIViewController *currentVC = [self currentViewController];
//    alertController = [UIAlertController alertControllerWithTitle:@"Wait please" message:@"Connecting to server ... " preferredStyle:UIAlertControllerStyleAlert];
//    
//    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(dismissLoadingViewWithAlert) userInfo:nil repeats:NO];
//    
//    [currentVC presentViewController:alertController animated:YES completion:aBlock];
//}

//+ (void)dismissLoadingView {
//    [alertController dismissViewControllerAnimated:YES completion:nil];
//}

//+ (void)dismissLoadingViewWithAlert {
//    [alertController dismissViewControllerAnimated:YES completion:^{
//        UIViewController *currentVC = [self currentViewController];
//        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"No connection" message:@"No connection to server. Please, try again later" preferredStyle:UIAlertControllerStyleAlert];
//        [alertVC addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
//            [alertVC dismissViewControllerAnimated:YES completion:nil];
//        }]];
//        [currentVC presentViewController:alertVC animated:YES completion:nil];
//    }];
//}

-(void)presentAlertControllerWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *alertVC = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction
                        actionWithTitle:@"Ok"
                        style:UIAlertActionStyleDefault
                        handler:^(UIAlertAction* action) {
                            [alertVC dismissViewControllerAnimated:YES completion:nil];
                        }
    ]];
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
