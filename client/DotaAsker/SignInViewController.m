//
//  SignInViewController.m
//  DotaAsker
//
//  Created by Artem on 18/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

// Libraries
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>

// Local
#import "SignInViewController.h"
#import "MainViewController.h"
#import "AuthorizationService.h"
#import "Player.h"
#import "ServiceLayer.h"
#import "ModalLoadingView.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

@synthesize textFieldUsername = _textFieldUsername;
@synthesize textFieldPassword = _textFieldPassword;
@synthesize strUsername = _strUsername;
@synthesize strPassword = _strPassword;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    NSString* strUnicodeRegexp = @"^[a-zA-Z0-9\\xC0-\\uFFFF]{3,20}$";
    NSString* strASCIIRegexp = @"^[a-zA-Z0-9]{3,20}$";
    
    __block NSRegularExpression* usernameRegexp = [NSRegularExpression regularExpressionWithPattern:strUnicodeRegexp options:0 error:0];
    __block NSRegularExpression* passwordRegexp = [NSRegularExpression regularExpressionWithPattern:strASCIIRegexp options:0 error:0];
    
    RACSignal* textSignalValid = [_textFieldUsername.rac_textSignal map:^(NSString* value) {
        return @([usernameRegexp numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])] == 1);
    }];
    RACSignal* textValid = [RACObserve(_textFieldUsername, text) map:^(NSString* value) {
        return @([usernameRegexp numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])] == 1);
    }];
    RACSignal* signalUsername = [[RACSignal combineLatest:@[textSignalValid, textValid]] or];
    
    
    RACSignal* passwordTextSignalValid = [_textFieldPassword.rac_textSignal map:^(NSString* value) {
        return @([passwordRegexp numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])] == 1);
    }];
    RACSignal* passwordTextValid = [RACObserve(_textFieldPassword, text) map:^(NSString* value) {
        return @([passwordRegexp numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])] == 1);
    }];
    RACSignal* signalPassword = [[RACSignal combineLatest:@[passwordTextSignalValid, passwordTextValid]] or];
    
    RAC(self.signInButton, enabled) = [[RACSignal combineLatest:@[signalUsername, signalPassword]] and];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
    self.sheetView.layer.cornerRadius = 8;
    self.sheetView.layer.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.4].CGColor;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_textFieldUsername setText:_strUsername];
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
    [self.view endEditing:YES];
    NSString *username = [_textFieldUsername text];
    NSString *password = [_textFieldPassword text];
    
    ModalLoadingView* loadingView = [[ModalLoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50) andMessage:NSLocalizedString(@"Getting user", 0)];
    [[[UIApplication sharedApplication] keyWindow] addSubview:loadingView];
    
    void (^errorBlock)(NSError* _Nonnull error) = ^void(NSError* _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentAlertControllerWithMessage:[error localizedDescription]];
            [loadingView removeFromSuperview];
        });
    };
    
    void (^completeBlock)() = ^void() {
        RACReplaySubject* subject = [[[ServiceLayer instance] userService] obtainWithAccessToken:[[[ServiceLayer instance] authorizationService] accessToken]];
        [subject subscribeNext:^(id u) {
            [Player manualUpdate:u];
        } error:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadingView removeFromSuperview];
                [self presentAlertControllerWithMessage:[error localizedDescription]];
            });
        } completed:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadingView removeFromSuperview];
                [self performSegueWithIdentifier:@"showMain" sender: self];
            });
        }];
    };
    
    RACSignal *signal = [[[ServiceLayer instance] authorizationService] getTokenForUsername:username andPassword:password];
    [signal subscribeNext:^(NSString* _token) {
        [[[ServiceLayer instance] authorizationService] setAccessToken:_token];
    } error:^(NSError *error) {
        [loadingView removeFromSuperview];
        [self presentAlertControllerWithMessage:[error localizedDescription]];
    } completed:^{
        // save username and password to user defaults
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:username forKey:@"username"];
        [defaults setObject:password forKey:@"password"];
        [Player synchronizeWithErrorBlock:errorBlock completionBlock:completeBlock];
    }];
    
}

- (IBAction)signUpPressed {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"username"];
    [defaults removeObjectForKey:@"password"];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)forgetPasswordPressed:(id)sender {
    [self performSegueWithIdentifier:@"forgetPassword" sender:sender];
}

@end
