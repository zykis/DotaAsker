//
//  UIViewController+BackgroundImage.m
//  DotaAsker
//
//  Created by Artem on 19/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "UIViewController+Utils.h"
#import "Player.h"
#import "TTGSnackbar-Swift.h"
#import "Palette.h"
#import "ModalLoadingView.h"

@implementation UIViewController (BackgroundImage)

- (void)loadBackgroundImage {
    [self loadBackgroundImage:[[Palette shared] pattern]];
}

- (void)loadBackgroundImage: (UIImage*)backgroundImage {
    [self loadBackgroundImage:backgroundImage atView:self.view];
}

- (void)loadBackgroundImageForView:(UIView *)view {
    [self loadBackgroundImage:[[Palette shared] pattern] atView:view];
}

- (void)loadBackgroundImage: (UIImage*)backgroundImage atView:(UIView*)view {
    UIGraphicsBeginImageContext(backgroundImage.size);
    // First fill the background with white.
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Get colors from palette
    UIColor* backgroundColor = [[Palette shared] backgroundColor];
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    [backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    CGContextSetRGBFillColor(context, red, green, blue, alpha);
    CGContextFillRect(context, view.frame);
    CGContextSaveGState(context);
    [backgroundImage drawAsPatternInRect:view.frame];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    view.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (void)presentAlertControllerWithMessage:(NSString *)message {
    TTGSnackbar* snackBar = [[TTGSnackbar alloc] initWithMessage:message duration:TTGSnackbarDurationMiddle];
    
    float m = 0;
    [snackBar setTopMargin:m];
    [snackBar setBottomMargin:m];
    [snackBar setLeftMargin:m];
    [snackBar setRightMargin:m];
    [snackBar setCornerRadius:0];
    [snackBar setMessageTextAlign:NSTextAlignmentCenter];
    
    [snackBar setBackgroundColor:[UIColor colorWithRed:0.87 green:0.17 blue:0.00 alpha:0.84]];
    [snackBar show];
}

- (void)presentOkControllerWithMessage:(NSString *)message {
    TTGSnackbar* snackBar = [[TTGSnackbar alloc] initWithMessage:message duration:TTGSnackbarDurationShort];
    
    float m = 0;
    [snackBar setTopMargin:m];
    [snackBar setBottomMargin:m];
    [snackBar setLeftMargin:m];
    [snackBar setRightMargin:m];
    [snackBar setCornerRadius:0];
    [snackBar setMessageTextAlign:NSTextAlignmentCenter];
    
    [snackBar setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.5]];
    [snackBar show];
}

- (void)hideLoadingViewIfPresented {
    for (UIView* subview in [[[UIApplication sharedApplication] keyWindow] subviews]) {
        if ([subview isKindOfClass:[ModalLoadingView class]]) {
            [subview removeFromSuperview];
        }
    }
}

@end
