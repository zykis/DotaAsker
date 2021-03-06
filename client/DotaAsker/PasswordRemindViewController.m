//
//  PasswordRemindViewController.m
//  DotaAsker
//
//  Created by Artem on 10/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

// Local
#import "PasswordRemindViewController.h"
#import "Helper.h"
#import "ModalLoadingView.h"
#import "UIViewController+Utils.h"

// Libraries
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>

@interface PasswordRemindViewController ()

@end

@implementation PasswordRemindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (IBAction)backButtonPressed {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)sendNewPassword:(id)sender {
    ModalLoadingView* loadingView = [[ModalLoadingView alloc] initWithMessage:NSLocalizedString(@"Sending email", 0)];
    [[[UIApplication sharedApplication] keyWindow] addSubview:loadingView];
    
    NSString* userOrEmail = [self.usernameOrEmail text];
    RACReplaySubject* subject = [[Helper shared] sendNewPasswordToUserOrEmail:userOrEmail];
    [subject subscribeNext:^(id x) {
        [self presentOkControllerWithMessage:NSLocalizedString(@"New password was sent", 0)];
        [loadingView removeFromSuperview];
        [self.navigationController popViewControllerAnimated:YES];
    } error:^(NSError *error) {
        [self presentAlertControllerWithMessage:NSLocalizedString(@"No such username or email", 0)];
        [loadingView removeFromSuperview];
        
    }];
}
@end
