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

+ (void)presentLoadingView{
    
}

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
