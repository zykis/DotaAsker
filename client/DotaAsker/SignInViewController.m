//
//  SignInViewController.m
//  DotaAsker
//
//  Created by Artem on 18/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "SignInViewController.h"
#import "Client.h"
#import "Player.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

@synthesize authorized = _authorized;
@synthesize navigationBar = _navigationBar;

- (void)viewDidLoad {
    _authorized = NO;
    [super viewDidLoad];
    [self initNotifications];
    [self loadBackgroundImage];
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
//            [self signIn];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationRecievedSignInSucceed) name:@"signin succeed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationRecievedSignInFailed:) name:@"signin failed" object:nil];
}

- (void)onNotificationRecievedSignInSucceed {
    _authorized = YES;
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] isEqualToString:[_username text]]) {
        [[NSUserDefaults standardUserDefaults] setObject:[_username text]  forKey:@"username"];
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"password"] isEqualToString:[_password text]]) {
            [[NSUserDefaults standardUserDefaults] setObject:[_password text]  forKey:@"password"];
        }
    }
    //Filling up Player's data:
    [[Client instance] sendMessageGetPlayerInfo:[_username text]];
    //Moving forward
    [self performSegueWithIdentifier:@"signin" sender:self];
}

- (void)onNotificationRecievedSignInFailed: (NSNotification*)aNotification {
    [self presentAlertControllerWithTitle:@"Signing in" andMessage:[NSString stringWithFormat:@"Failed: %@",[aNotification.userInfo objectForKey:@"reason"]]];
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
    [[Client instance] sendMessageSignInWithUsername:strUsername andPassword:strPassword];
}

- (IBAction)backButtonPressed {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"signin"]) {
        if (_authorized) {
            return YES;
        }
    }
    return NO;
}

@end
