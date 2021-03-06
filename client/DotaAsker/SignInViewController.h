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
@property (strong, nonatomic) IBOutlet UIView *sheetView;
@property (strong, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) NSString* strUsername;
@property (strong, nonatomic) NSString* strPassword;
- (IBAction)signIn;
- (IBAction)signUpPressed;
- (IBAction)forgetPasswordPressed:(id)sender;


@end
