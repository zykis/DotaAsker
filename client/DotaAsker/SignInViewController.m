//
//  SignInViewController.m
//  DotaAsker
//
//  Created by Artem on 18/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "SignInViewController.h"
#import "ServiceLayer.h"
#import "MainViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

@synthesize authorized = _authorized;
@synthesize navigationBar = _navigationBar;
@synthesize player = _player;

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
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] isEqualToString:@""]) {
        if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"password"] isEqualToString:@""]) {
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
    NSString* errorString;
    if (![[[ServiceLayer instance] authorizationService] fitsUsername:strUsername andPassword:strPassword error:&errorString]) {
        [self presentAlertControllerWithTitle:@"Incorrect fields" andMessage:errorString];
        return;
    }
    
    _authorized = [[[ServiceLayer instance] authorizationService] authWithLogin:strUsername andPassword:strPassword errorString:&errorString];
    
    if (_authorized) {
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] isEqualToString:[_username text]]) {
            [[NSUserDefaults standardUserDefaults] setObject:[_username text]  forKey:@"username"];
            if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"password"] isEqualToString:[_password text]]) {
                [[NSUserDefaults standardUserDefaults] setObject:[_password text]  forKey:@"password"];
            }
        }
        _player = [[[ServiceLayer instance] playerService] obtainPlayerWithUsername:[_username text]];
        if (_player) {
            [self performSegueWithIdentifier:@"signin" sender:self];
        }
        else {
            [self presentAlertControllerWithTitle:@"Signing in failed" andMessage:[NSString stringWithFormat:@"Server error"]];
        }
    }
    else {
        [self presentAlertControllerWithTitle:@"Signing in failed" andMessage:[NSString stringWithFormat:@"%@", errorString]];
    }
}

- (IBAction)backButtonPressed {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (_player) {
        MainViewController* destVC = (MainViewController*)[segue destinationViewController];
        [destVC setPlayer:_player];
    }
    else {
        return;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"signin"])
        if (_authorized)
            if (_player)
                return YES;
    return NO;
}

@end
