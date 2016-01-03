//
//  UIViewController+BackgroundImage.h
//  DotaAsker
//
//  Created by Artem on 19/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>

static UIAlertController *alertController;

@interface UIViewController (BackgroundImage)
- (void)loadBackgroundImage;
//+ (void)presentLoadingViewAndCompleteWith:(void (^)(void))aBlock;
//+ (void)dismissLoadingView;
-(void) presentAlertControllerWithTitle: (NSString*)title andMessage:(NSString*)message;
+(UIViewController*) currentViewController;
@end
