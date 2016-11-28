//
//  SettingViewController.h
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"
#import "PressButton.h"

@interface SettingViewController : UIViewController
- (IBAction)backButtonPushed:(id)sender;
- (void)avatarsPushed;
- (void)questionPushed;
- (void)premiumPushed;
- (void)top100Pushed;
@property (strong, nonatomic) IBOutlet PressButton *questionButton;
@property (strong, nonatomic) IBOutlet PressButton *top100Button;
@property (strong, nonatomic) IBOutlet PressButton *avatarsButton;
@property (strong, nonatomic) IBOutlet PressButton *premiumButton;
- (BOOL)checkPremium;
@end
