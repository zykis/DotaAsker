//
//  UIViewController+BackgroundImage.m
//  DotaAsker
//
//  Created by Artem on 19/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "UIViewController+Utils.h"
#import "Player.h"
#import "TTGSnackBar-Swift.h"

@implementation UIViewController (BackgroundImage)

- (void)loadBackgroundImage: (UIImage*)backgroundImage {
    UIGraphicsBeginImageContext(self.view.frame.size);
    [backgroundImage drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (void)presentAlertControllerWithTitle:(NSString *)title andMessage:(NSString *)message {
    TTGSnackbar* snackBar = [[TTGSnackbar alloc] initWithMessage:message duration:TTGSnackbarDurationLong];
    [snackBar setBackgroundColor:[UIColor redColor]];
    [snackBar setSeparateViewBackgroundColor:[UIColor colorWithRed:183 green:28 blue:28 alpha:1.0]];
    
    [snackBar show];
}

@end
