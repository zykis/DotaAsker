//
//  ViewController.m
//  DotaAsker
//
//  Created by Artem on 07/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "AuthorizationViewController.h"
#import "ServiceLayer.h"

@interface AuthorizationViewController ()

@end

@implementation AuthorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES];
    [self loadBackgroundImage:[[[ServiceLayer instance] userService] wallpapersDefault]];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"username"] != nil) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"password"] != nil) {
            [self performSegueWithIdentifier:@"signin" sender:self];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
