//
//  SignInViewController.m
//  DotaAsker
//
//  Created by Artem on 18/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "SignInViewController.h"
#import "MainViewController.h"
#import "AuthorizationService.h"
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
#import "APIHelper.h"
#import "Player.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

@synthesize navigationBar = _navigationBar;
@synthesize textFieldUsername = _textFieldUsername;
@synthesize textFieldPassword = _textFieldPassword;
@synthesize strUsername = _strUsername;
@synthesize strPassword = _strPassword;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* strUnicodeRegexp = @"^[a-zA-Z0-9\\xC0-\\uFFFF]{3,20}$";
    NSString* strASCIIRegexp = @"^[a-zA-Z0-9]{3,20}$";
    
    __block NSRegularExpression* usernameRegexp = [NSRegularExpression regularExpressionWithPattern:strUnicodeRegexp options:0 error:0];
    __block NSRegularExpression* passwordRegexp = [NSRegularExpression regularExpressionWithPattern:strASCIIRegexp options:0 error:0];
    
    RACSignal* validUsername = [self.textFieldUsername.rac_textSignal map:^id(NSString* value) {
        return @([usernameRegexp numberOfMatchesInString:value options:0
                                                   range:NSMakeRange(0, [value length])] == 1);
    }];
    RACSignal* validPassword = [self.textFieldPassword.rac_textSignal map:^id(NSString* value) {
        return @([passwordRegexp numberOfMatchesInString:value options:0
                                                   range:NSMakeRange(0, [value length])] == 1);
    }];
    
    RAC(self.signInButton, enabled) = [[RACSignal combineLatest:@[ validUsername, validPassword ]] and];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![_strUsername isEqualToString:@""])
        [_textFieldUsername setText:_strUsername];
    if (![_strPassword isEqualToString:@""])
        [_textFieldPassword setText:_strPassword];
    
    if (![[_textFieldUsername text] isEqualToString:@""] && ![[_textFieldPassword text] isEqualToString:@""]) {
        [self signIn];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signIn {
    NSString *username = [_textFieldUsername text];
    NSString *password = [_textFieldPassword text];
    
    RACSignal *signal = [[AuthorizationService instance] getTokenForUsername:username andPassword:password];
    
    [signal subscribeNext:^(NSString* _token) {
        [[AuthorizationService instance] setAccessToken:_token];
    } error:^(NSError *error) {
        [self presentAlertControllerWithTitle:@"Error" andMessage:[error localizedDescription]];
    } completed:^{
        [[[APIHelper shared] getPlayerWithToken:[[AuthorizationService instance] accessToken]] subscribeNext:^(User* u) {
            [Player setPlayer:u];
            [self performSegueWithIdentifier:@"signin" sender:self];
        } error:^(NSError *error) {
            [self presentAlertControllerWithTitle:@"Error" andMessage:[error localizedDescription]];
        }];
    }];
}

- (IBAction)backButtonPressed {
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
