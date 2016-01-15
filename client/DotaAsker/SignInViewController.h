//
//  SignInViewController.h
//  DotaAsker
//
//  Created by Artem on 18/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"
#import "Player.h"

@interface SignInViewController : UIViewController
@property (strong, nonatomic) Player* player;
@property (assign, nonatomic) BOOL authorized;
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
- (IBAction)signIn;
- (IBAction)backButtonPressed;

@end
