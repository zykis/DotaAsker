//
//  UnlockPremiumViewController.h
//  DotaAsker
//
//  Created by Artem on 24/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

// Local
#import "UIViewController+Utils.h"

// iOS
#import <UIKit/UIKit.h>

@class ModalLoadingView;
@class SettingsButton;
@class IAPHelper;


@interface UnlockPremiumViewController : UIViewController
- (IBAction)unlockPressed;
@property (strong, nonatomic) IBOutlet SettingsButton* unlockButton;
@property (weak, nonatomic) IBOutlet UIStackView* verticalStackView;
@property (strong, nonatomic) ModalLoadingView* loadingView;
@property (strong, nonatomic) IAPHelper* helper;
- (IBAction)restorePushed:(id)sender;

@end
