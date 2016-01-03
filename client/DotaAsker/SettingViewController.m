//
//  SettingViewController.m
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "SettingViewController.h"
#import "Player.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    // Do any additional setup after loading the view.
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

@end
