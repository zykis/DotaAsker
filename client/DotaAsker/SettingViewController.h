//
//  SettingViewController.h
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

// Local
#import "UIViewController+Utils.h"

// iOS
#import <UIKit/UIKit.h>

@class SettingsButton;

@interface SettingViewController : UIViewController
@property (strong, nonatomic) IBOutlet SettingsButton *unlockButton;
- (IBAction)backButtonPushed:(id)sender;
- (IBAction)avatarsPushed;
- (IBAction)questionPushed;
- (IBAction)premiumPushed;
- (IBAction)top100Pushed;
- (BOOL)checkPremium;
@end
