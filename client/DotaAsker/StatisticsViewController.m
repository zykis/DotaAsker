//
//  StatisticsViewController.m
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "StatisticsViewController.h"
#import "Player.h"

@interface StatisticsViewController ()

@end

@implementation StatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (IBAction)backButtonPushed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
