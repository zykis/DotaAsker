//
//  ViewController.m
//  DotaAsker
//
//  Created by Artem on 07/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

// Local
#import "AuthorizationViewController.h"
#import "ServiceLayer.h"
#import "SignInViewController.h"
#import "Palette.h"
#import "ModalLoadingView.h"

// Libraries
#import <ReactiveObjC/ReactiveObjC.h>


@interface AuthorizationViewController ()

@end

@implementation AuthorizationViewController

@synthesize loadingView = _loadingView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    [[self navigationController] setNavigationBarHidden:YES];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    _loadingView = [[ModalLoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50) andMessage:@""];
    
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
    
    RAC(self.buttonSign, enabled) = [[RACSignal combineLatest:@[ validUsername, validPassword ]] and];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    self.username = [defaults valueForKey:@"username"];
    self.password = [defaults valueForKey:@"password"];
    if ((self.username != nil) && (self.password != nil)) {
        [self setupSignIn];
        [self signIn];
    }
    else {
        [self setupSignUp];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showMain"]) {
        if ((self.username != nil) && (self.password != nil)) {
            SignInViewController* destVC = [segue destinationViewController];
            [destVC setStrUsername:self.username];
            [destVC setStrPassword:self.password];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signPressed:(id)sender {
    if (self.currentTabSignIn)
        [self signIn];
    else
        [self signUp];
}

- (IBAction)forgetPasswordPressed:(id)sender {
    [self performSegueWithIdentifier:@"forgetPassword" sender:sender];
}

- (IBAction)signUpPressed:(id)sender {
    [self setupSignUp];
}

- (IBAction)signInPressed:(id)sender {
    [self setupSignIn];
}

- (void)setupSignUp {
    self.currentTabSignIn = NO;
    [self.buttonSign setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.textFieldEmail setHidden:NO];
    [self.buttonForgetPassword setHidden:YES];
}

- (void)setupSignIn {
    self.currentTabSignIn = YES;
    [self.buttonSign setTitle:@"Log in" forState:UIControlStateNormal];
    [self.textFieldEmail setHidden:YES];
    [self.buttonForgetPassword setHidden:NO];
}

- (void)signUp {
    [_loadingView setMessage:@"Registering player"];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_loadingView];
    
    [self.view endEditing:YES];
    RACSignal* authorizationSignal = [[[ServiceLayer instance] authorizationService] signUpWithLogin:[_textFieldUsername text] andPassword:[_textFieldPassword text] email:[_textFieldEmail text]];
    
    [authorizationSignal subscribeError:^(NSError *error) {
        [_loadingView removeFromSuperview];
        [self presentAlertControllerWithMessage:[error localizedDescription]];
    } completed:^{
        [self signIn];
    }];
}

- (void)signIn {
    NSString *username = [_textFieldUsername text];
    NSString *password = [_textFieldPassword text];
    
    [_loadingView setMessage:@"Getting user"];
    if (![[[[UIApplication sharedApplication] keyWindow] subviews] containsObject:_loadingView])
        [[[UIApplication sharedApplication] keyWindow] addSubview:_loadingView];
    
    
    void (^errorBlock)(NSError* _Nonnull error) = ^void(NSError* _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentAlertControllerWithMessage:[error localizedDescription]];
            [_loadingView removeFromSuperview];
        });
    };
    
    void (^completeBlock)() = ^void() {
        RACReplaySubject* subject = [[[ServiceLayer instance] userService] obtainWithAccessToken:[[[ServiceLayer instance] authorizationService] accessToken]];
        [subject subscribeNext:^(id u) {
            [Player manualUpdate:u];
        } error:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_loadingView removeFromSuperview];
                [self presentAlertControllerWithMessage:[error localizedDescription]];
            });
        } completed:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [_loadingView removeFromSuperview];
                [self performSegueWithIdentifier:@"showMain" sender: self];
            });
        }];
    };
    
    RACSignal *signal = [[[ServiceLayer instance] authorizationService] getTokenForUsername:username andPassword:password];
    [signal subscribeNext:^(NSString* _token) {
        [[[ServiceLayer instance] authorizationService] setAccessToken:_token];
    } error:^(NSError *error) {
        [_loadingView removeFromSuperview];
        [self presentAlertControllerWithMessage:[error localizedDescription]];
    } completed:^{
        // save username and password to user defaults
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:username forKey:@"username"];
        [defaults setObject:password forKey:@"password"];
        [Player synchronizeWithErrorBlock:errorBlock completionBlock:completeBlock];
    }];
}

@end
