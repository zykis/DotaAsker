//
//  SignUpViewController.m
//  DotaAsker
//
//  Created by Artem on 18/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "SignUpViewController.h"
#import "ServiceLayer.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

@synthesize authorized = _authorized;

- (void)viewDidLoad {
    _authorized = NO;
    [super viewDidLoad];
    UIImage* walpapers = [[[ServiceLayer instance] userService] wallpapersDefault];
    [self loadBackgroundImage:walpapers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onNotificationRecievedSignUpFailed: (NSNotification*)aNotification {
    [self presentAlertControllerWithTitle:@"Signing up" andMessage:[NSString stringWithFormat:@"Failed: %@",[aNotification.userInfo objectForKey:@"reason"]]];
}

- (void)onNotificationRecievedSignInSucceed {
    [self performSegueWithIdentifier:@"signup" sender:self];
}

- (IBAction)signUp {
    NSString *strUsername = [_username text];
    NSString *strPassword = [_password text];
    NSString *strEmail = [_email text];
    NSString *errorString;
    if ([[_username text] length] <= 3) {
        [self presentAlertControllerWithTitle:@"Username incorrect:" andMessage:[NSString stringWithFormat:@"should be 3 symbols at least"]];
        return;
    }
    else if ([[_password text] isEqualToString:@""]) {
        [self presentAlertControllerWithTitle:@"Password" andMessage:[NSString stringWithFormat:@"shouldn't be empty"]];
        return;
    }
    BOOL bSignedUp = [[[ServiceLayer instance] authorizationService] signUpWithLogin:strUsername andPassword:strPassword email:strEmail errorString:&errorString];
    if (bSignedUp) {
        _authorized = YES;
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] isEqualToString:[_username text]]) {
            [[NSUserDefaults standardUserDefaults] setObject:[_username text]  forKey:@"username"];
            if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"password"] isEqualToString:[_password text]]) {
                [[NSUserDefaults standardUserDefaults] setObject:[_password text]  forKey:@"password"];
            }
        }
        [self performSegueWithIdentifier:@"signup" sender:self];
    }
}

- (IBAction)backButtonPressed {
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
