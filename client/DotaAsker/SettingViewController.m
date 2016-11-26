//
//  SettingViewController.m
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "SettingViewController.h"
#import "ServiceLayer.h"
#import "Player.h"
#import "PressButton.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // [1] Question Button
    UIView* buttonQuestion = [self.view viewWithTag:100];
    buttonQuestion.layer.cornerRadius = 3.0;
    
    buttonQuestion.layer.borderWidth = 2.0;
    buttonQuestion.layer.borderColor = [[UIColor clearColor] CGColor];
    
    buttonQuestion.layer.shadowColor = [UIColor colorWithRed:0 green:(100.0f/255.0f) blue:0.0 alpha:1.0].CGColor;
    buttonQuestion.layer.shadowOpacity = 1.0f;
    buttonQuestion.layer.shadowRadius = 1.0f;
    buttonQuestion.layer.shadowOffset = CGSizeMake(0, 3);
    UITapGestureRecognizer* tapRecognizerQuestion = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(questionPushed)];
    [buttonQuestion addGestureRecognizer:tapRecognizerQuestion];
    
    // [2] Avatar Button
    UIView* buttonAvatar = [self.view viewWithTag:101];
    buttonAvatar.layer.cornerRadius = 3.0;
    
    buttonAvatar.layer.borderWidth = 2.0;
    buttonAvatar.layer.borderColor = [[UIColor clearColor] CGColor];
    
    buttonAvatar.layer.shadowColor = [UIColor colorWithRed:0 green:(100.0f/255.0f) blue:0.0 alpha:1.0].CGColor;
    buttonAvatar.layer.shadowOpacity = 1.0f;
    buttonAvatar.layer.shadowRadius = 1.0f;
    buttonAvatar.layer.shadowOffset = CGSizeMake(0, 3);
    UITapGestureRecognizer* tapRecognizerAvatar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarsPushed)];
    [buttonAvatar addGestureRecognizer:tapRecognizerAvatar];
    
    // [3] Top100 Button
    UIView* buttonTop100 = [self.view viewWithTag:102];
    buttonTop100.layer.cornerRadius = 3.0;
    
    buttonTop100.layer.borderWidth = 2.0;
    buttonTop100.layer.borderColor = [[UIColor clearColor] CGColor];
    
    buttonTop100.layer.shadowColor = [UIColor colorWithRed:0 green:(100.0f/255.0f) blue:0.0 alpha:1.0].CGColor;
    buttonTop100.layer.shadowOpacity = 1.0f;
    buttonTop100.layer.shadowRadius = 1.0f;
    buttonTop100.layer.shadowOffset = CGSizeMake(0, 3);
    UITapGestureRecognizer* tapRecognizerTop100 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(top100Pushed)];
    [buttonTop100 addGestureRecognizer:tapRecognizerTop100];
    
    // [4] Premium Button
    UIView* buttonPremium = [self.view viewWithTag:103];
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(premiumPushed)];
    [buttonPremium addGestureRecognizer:tapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPushed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)questionPushed {
    [self performSegueWithIdentifier:@"submit_question" sender:self];
}

- (void)avatarsPushed {
    if ([self checkPremium])
        [self performSegueWithIdentifier:@"change_avatar" sender:self];
}

- (void)premiumPushed {
    [self performSegueWithIdentifier:@"unlock_premium" sender:self];
}

- (void)top100Pushed {
    if ([self checkPremium])
        [self performSegueWithIdentifier:@"top100" sender:self];
}

- (BOOL)checkPremium {
    if (![[Player instance] premium]) {
        [self presentAlertControllerWithTitle:@"Sorry" andMessage:@"Premium account only"];
        return NO;
    }
    else
        return YES;
}

@end
