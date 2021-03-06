//
//  SettingViewController.m
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

// Local
#import "SettingViewController.h"
#import "ServiceLayer.h"
#import "Player.h"
#import "Top100ViewController.h"
#import "ModalLoadingView.h"
#import "SettingsButton.h"

// iOS
#import <StoreKit/StoreKit.h>

// Libraries
#import <ReactiveObjC/ReactiveObjC.h>

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear: (BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideLoadingViewIfPresented];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (IBAction)backButtonPushed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)questionPushed {
    [self performSegueWithIdentifier:@"submit_question" sender:self];
}

- (IBAction)avatarsPushed {
    if ([self checkPremium])
        [self performSegueWithIdentifier:@"change_avatar" sender:self];
    else
        [self presentAlertControllerWithMessage:NSLocalizedString(@"Premium account only", 0)];
}

- (IBAction)premiumPushed {
    if (![self checkPremium])
        [self performSegueWithIdentifier:@"unlock_premium" sender:self];
    else
        [self presentOkControllerWithMessage:NSLocalizedString(@"You already have premium", 0)];
}

- (IBAction)top100Pushed {
    if ([self checkPremium]) {
        // Present LoadingView
        __block ModalLoadingView* loadingView = [[ModalLoadingView alloc] initWithMessage:NSLocalizedString(@"Getting top 100", 0)];
        [[[UIApplication sharedApplication] keyWindow] addSubview:loadingView];
    
        __block NSDictionary* results;
        RACReplaySubject* subject = [[[ServiceLayer instance] userService] top100];
        [subject subscribeNext:^(id x) {
            results = x;
        } error:^(NSError *error) {
            [loadingView removeFromSuperview];
            [self presentAlertControllerWithMessage:[error localizedDescription]];
        } completed:^{
            [loadingView removeFromSuperview];
            [self performSegueWithIdentifier:@"top100" sender:results];
        }];
    }
    else {
        [self presentAlertControllerWithMessage:NSLocalizedString(@"Premium account only", 0)];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"top100"]) {
        Top100ViewController* destVC = (Top100ViewController*)[segue destinationViewController];
        destVC.results = sender;
    }
}

- (BOOL)checkPremium {
    if (![[Player instance] premium]) {
        return NO;
    }
    else {
        return YES;
    }
}

@end
