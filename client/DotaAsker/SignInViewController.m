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
    
    RACSignal* validUsername = [self.textFieldUsername.rac_textSignal map:^id(NSString* value) {
        return @([usernameRegexp numberOfMatchesInString:value options:0
                                                   range:NSMakeRange(0, [value length])] == 1);
    }];
    RACSignal* validPassword = [self.textFieldPassword.rac_textSignal map:^id(NSString* value) {
        return @([passwordRegexp numberOfMatchesInString:value options:0
                                                   range:NSMakeRange(0, [value length])] == 1);
    }];
    
    RAC(self.signInButton, enabled) = [[RACSignal combineLatest:@[ validUsername, validPassword ]] and];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:animated];
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
    [self.view endEditing:YES];
    NSString *username = [_textFieldUsername text];
    NSString *password = [_textFieldPassword text];
    
    // Present LoadingView
    __block ModalLoadingView* loadingView = [[ModalLoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50) andMessage:@"Sending answers"];
    [[[UIApplication sharedApplication] keyWindow] addSubview:loadingView];
    
    void (^errorBlock)(NSError* _Nonnull error) = ^void(NSError* _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentAlertControllerWithMessage:[error localizedDescription]];
            [loadingView removeFromSuperview];
        });
    };
    
    void (^completeBlock)() = ^void() {
        // UserAnswers has been updated.
        // Updaing Player and tableView
        [loadingView setMessage:@"Getting player"];
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
                [self performSegueWithIdentifier:@"signin" sender: self];
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

- (IBAction)backButtonPressed {
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
