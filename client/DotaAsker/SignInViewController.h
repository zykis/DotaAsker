//
//  SignInViewController.h
//  DotaAsker
//
//  Created by Artem on 18/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"

@interface SignInViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) NSString* strUsername;
@property (strong, nonatomic) NSString* strPassword;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
- (IBAction)signIn;
- (IBAction)backButtonPressed;

@end
