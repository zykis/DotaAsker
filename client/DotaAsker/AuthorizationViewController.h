//
//  ViewController.h
//  DotaAsker
//
//  Created by Artem on 07/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//


// Local
#import "UIViewController+Utils.h"

// Libraries
#import <UIKit/UIKit.h>

@class ModalLoadingView;


@interface AuthorizationViewController : UIViewController

@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* password;
@property (strong, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (strong, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (strong, nonatomic) IBOutlet UIButton *buttonForgetPassword;
@property (strong, nonatomic) IBOutlet UIButton *buttonSignUp;
@property (strong, nonatomic) IBOutlet UIButton *buttonSignIn;
@property (strong, nonatomic) IBOutlet UIButton *buttonSign;
@property (strong, nonatomic) ModalLoadingView* loadingView;

- (IBAction)signPressed:(id)sender;
- (IBAction)forgetPasswordPressed:(id)sender;
- (IBAction)signUpPressed:(id)sender;
- (IBAction)signInPressed:(id)sender;
- (void)setupSignUp;
- (void)setupSignIn;
- (void)signUp;
- (void)signIn;

@end

