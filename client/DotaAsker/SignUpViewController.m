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
@synthesize _textFieldEmail = _textFieldEmail;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    NSString* strUnicodeRegexp = @"^[a-zA-Z0-9\\xC0-\\uFFFF]{3,20}$";
    NSString* strASCIIRegexp = @"^[a-zA-Z0-9]{3,20}$";
    
    __block NSRegularExpression* usernameRegexp = [NSRegularExpression regularExpressionWithPattern:strUnicodeRegexp options:0 error:0];
    __block NSRegularExpression* passwordRegexp = [NSRegularExpression regularExpressionWithPattern:strASCIIRegexp options:0 error:0];
    
    RACSignal* signalUsername = [RACSignal combineLatest:@[_textFieldUsername.rac_textSignal, RACObserve(_textFieldUsername, text)]];
    RACSignal* validUsername = [signalUsername map:^id(NSString* value) {
        return @([usernameRegexp numberOfMatchesInString:value options:0
                                                              range:NSMakeRange(0, [value length])] == 1);
    }];
    
    RACSignal* signalPassword = [RACSignal combineLatest:@[_textFieldPassword.rac_textSignal, RACObserve(_textFieldPassword, text)]];
    RACSignal* validPassword = [signalPassword map:^id(NSString* value) {
        return @([passwordRegexp numberOfMatchesInString:value options:0
                                                                        range:NSMakeRange(0, [value length])] == 1);
    }];
    
    RAC(self.signUpButton, enabled) = [RACSignal combineLatest:@[validUsername, validPassword]];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUp {
    [_loadingView setMessage:@"Registering player"];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_loadingView];
    
    [self.view endEditing:YES];
    RACSignal* authorizationSignal = [[[ServiceLayer instance] authorizationService] signUpWithLogin:[_textFieldUsername text] andPassword:[_textFieldPassword text] email:[_textFieldEmail text]];
    
    [authorizationSignal subscribeError:^(NSError *error) {
        [_loadingView removeFromSuperview];
        [self presentAlertControllerWithMessage:[error localizedDescription]];
    } completed:^{
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
    _textFieldPassword.text = @"";
    _textFieldPassword.text = @"";
    [self performSegueWithIdentifier:@"signin" sender:self];
}
@end
