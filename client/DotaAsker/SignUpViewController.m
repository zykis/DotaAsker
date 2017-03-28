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
    
    RAC(self.signUpButton, enabled) = [[RACSignal combineLatest:@[ validUsername, validPassword ]] and];
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

- (IBAction)backButtonPressed:(id)sender {
}

- (IBAction)signUp {
    ModalLoadingView* loadingView = [[ModalLoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50) andMessage:@"Registering player"];
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

- (IBAction)backButtonPressed {
    [[self navigationController] popViewControllerAnimated:YES];
}
@end
