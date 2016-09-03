//
//  SignUpViewController.m
//  DotaAsker
//
//  Created by Artem on 18/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "SignUpViewController.h"
#import "AuthorizationService.h"

#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RACSignal* validUsername = [self.textFieldUsername.rac_textSignal map:^id(NSString* value) {
        return @([value length] > 2);
    }];
    
    RAC(self.signUpButton, enabled) = validUsername;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUp {
    RACSignal* authorizationSignal = [[AuthorizationService instance] signUpWithLogin:[_textFieldUsername text] andPassword:[_textFieldPassword text] email:[_textFieldEmail text]];
    [authorizationSignal subscribeError:^(NSError *error) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка"
                                                                       message:[[error userInfo] valueForKey:@"message"]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    } completed:^{
        [self performSegueWithIdentifier:@"signup" sender:self];
    }];
    
}

- (IBAction)backButtonPressed {
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
