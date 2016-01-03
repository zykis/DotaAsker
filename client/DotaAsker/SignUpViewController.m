//
//  SignUpViewController.m
//  DotaAsker
//
//  Created by Artem on 18/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "SignUpViewController.h"
#import "Client.h"
#import "Player.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

@synthesize authorized = _authorized;

- (void)viewDidLoad {
    _authorized = NO;
    [super viewDidLoad];
    [self initNotifications];
    [self loadBackgroundImage];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationRecievedSignUpSucceed) name:@"signup succeed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationRecievedSignUpFailed:) name:@"signup failed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationRecievedSignInSucceed) name:@"signin succeed" object:nil];
}

- (void)onNotificationRecievedSignUpSucceed {
    _authorized = YES;
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] isEqualToString:[_username text]]) {
        [[NSUserDefaults standardUserDefaults] setObject:[_username text]  forKey:@"username"];
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"password"] isEqualToString:[_password text]]) {
            [[NSUserDefaults standardUserDefaults] setObject:[_password text]  forKey:@"password"];
        }
    }
    [[Client instance] sendMessageSignInWithUsername:[_username text] andPassword:[_password text]];
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
    if ([[_username text] length] <= 3) {
        [self presentAlertControllerWithTitle:@"Username incorrect:" andMessage:[NSString stringWithFormat:@"should be 3 symbols at least"]];
        return;
    }
    else if ([[_password text] isEqualToString:@""]) {
        [self presentAlertControllerWithTitle:@"Password" andMessage:[NSString stringWithFormat:@"shouldn't be empty"]];
        return;
    }
    if (![[Client instance] connected]) {
        [[Client instance] connect];
    }
    [[Client instance] sendMessageSignUpWithUsername:strUsername andPassword:strPassword andEmail:strEmail];
}

- (IBAction)backButtonPressed {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"signup"]) {
        if (_authorized) {
            return YES;
        }
    }
    return NO;
}

@end
