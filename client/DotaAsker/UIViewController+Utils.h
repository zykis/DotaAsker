//
//  UIViewController+BackgroundImage.h
//  DotaAsker
//
//  Created by Artem on 19/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"

static UIAlertController *alertController;

@interface UIViewController (BackgroundImage)

@property (strong, nonatomic) LoadingView* loadingView;

- (void)loadBackgroundImage:(UIImage*)backgroundImage;
- (void)presentAlertControllerWithTitle: (NSString*)title andMessage:(NSString*)message;

@end
