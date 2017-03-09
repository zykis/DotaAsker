//
//  SettingViewController.h
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"

@interface SettingViewController : UIViewController
- (IBAction)backButtonPushed:(id)sender;
- (IBAction)avatarsPushed;
- (IBAction)questionPushed;
- (IBAction)premiumPushed;
- (IBAction)top100Pushed;

- (BOOL)checkPremium;
- (void)setupCompactWidth;
- (void)setupRegularWidth;
@end
