//
//  SignUpViewController.m
//  DotaAsker
//
//  Created by Artem on 18/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "SignUpViewController.h"
#import "SignInViewController.h"
#import "AuthorizationService.h"
#import "ServiceLayer.h"
#import "ModalLoadingView.h"

#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>

@interface SignUpViewController ()

@end

@implementation SignUpViewController

@synthesize textFieldUsername = _textFieldUsername;
@synthesize textFieldPassword = _textFieldPassword;
@synthesize textFieldEmail = _textFieldEmail;

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
    
    RAC(self.signUpButton, enabled) = [[RACSignal combineLatest:@[signalUsername, signalPassword]] and];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
    self.sheetView.layer.cornerRadius = 8;
    self.sheetView.layer.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.4].CGColor;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if (![[defaults objectForKey:@"username"] isEqualToString:@""])
        _textFieldUsername.text = [defaults objectForKey:@"username"];
    if (![[defaults objectForKey:@"password"] isEqualToString:@""])
        _textFieldPassword.text = [defaults objectForKey:@"password"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![_textFieldUsername.text isEqualToString:@""] && ![_textFieldPassword.text isEqualToString:@""])
        [self performSegueWithIdentifier:@"signin" sender:self];
}

- (void)viewWillDissapear: (BOOL)animated {
    [super viewWillDissapear:animated];
    [self hideLoadingViewIfPresented];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUp {
    ModalLoadingView* loadingView = [[ModalLoadingView alloc] initWithMessage:NSLocalizedString(@"Registering player", 0)];
    [[[UIApplication sharedApplication] keyWindow] addSubview:loadingView];
    
    [self.view endEditing:YES];
    RACSignal* authorizationSignal = [[[ServiceLayer instance] authorizationService] signUpWithLogin:[_textFieldUsername text] andPassword:[_textFieldPassword text] email:[_textFieldEmail text]];
    
    [authorizationSignal subscribeError:^(NSError *error) {
        [loadingView removeFromSuperview];
        [self presentAlertControllerWithMessage:[error localizedDescription]];
    } completed:^{
        [loadingView removeFromSuperview];
        [self performSegueWithIdentifier:@"signin" sender:self];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"signin"]) {
        SignInViewController* destVC = [segue destinationViewController];
        destVC.strUsername = [_textFieldUsername text];
        destVC.strPassword = [_textFieldPassword text];
    }
}

- (IBAction)signInPressed {
    [self performSegueWithIdentifier:@"signin" sender:self];
}
@end
