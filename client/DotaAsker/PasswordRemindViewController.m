//
//  PasswordRemindViewController.m
//  DotaAsker
//
//  Created by Artem on 10/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "PasswordRemindViewController.h"
#import "Helper.h"
#import "LoadingView.h"
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

- (IBAction)backButtonPressed {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)sendNewPassword:(id)sender {
    LoadingView* loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50)];
    [loadingView setMessage:@"Sending email"];
    [[self view] addSubview:loadingView];
    
    NSString* userOrEmail = [self.usernameOrEmail text];
    RACReplaySubject* subject = [[Helper shared] sendNewPasswordToUserOrEmail:userOrEmail];
    [subject subscribeNext:^(id x) {
        NSLog(@"New password was sent");
        [loadingView removeFromSuperview];
    } error:^(NSError *error) {
        NSLog(@"Error. No such username or email");
        [loadingView removeFromSuperview];
    }];
}
@end
