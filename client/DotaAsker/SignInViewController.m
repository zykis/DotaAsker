//
//  SignInViewController.m
//  DotaAsker
//
//  Created by Artem on 18/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "SignInViewController.h"
#import "ServiceLayer.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

@synthesize authorized = _authorized;
@synthesize navigationBar = _navigationBar;

- (void)viewDidLoad {
    _authorized = NO;
    [super viewDidLoad];
    UIImage* wallpapers;
    wallpapers = [[[ServiceLayer instance] userService] wallpapersDefault];
    [self loadBackgroundImage: wallpapers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"username"] != nil) {
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"password"] != nil) {
            [_username setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"]];
            [_password setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"password"]];
            [self signIn];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signIn {
    NSString *strUsername = [_username text];
    NSString *strPassword = [_password text];
    if ([[_username text] length] <= 3) {
        [self presentAlertControllerWithTitle:@"Username is incorrect" andMessage:@"should be 3 symblos at least"];
        return;
    }
    else if ([[_password text] isEqualToString:@""]) {
        [self presentAlertControllerWithTitle:@"Password" andMessage:@"shouldn't be empty"];
        return;
    }
    NSString* errorString;
    _authorized = [[[ServiceLayer instance] authorizationService] authWithLogin:strUsername andPassword:strPassword errorString:&errorString];
    
    if (_authorized) {
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] isEqualToString:[_username text]]) {
            [[NSUserDefaults standardUserDefaults] setObject:[_username text]  forKey:@"username"];
            if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"password"] isEqualToString:[_password text]]) {
                [[NSUserDefaults standardUserDefaults] setObject:[_password text]  forKey:@"password"];
            }
        }
        [self performSegueWithIdentifier:@"signin" sender:self];
    }
    else {
        [self presentAlertControllerWithTitle:@"Signing in" andMessage:[NSString stringWithFormat:@"Failed: %@", errorString]];
    }
}

- (IBAction)backButtonPressed {
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
