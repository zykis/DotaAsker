//
//  ViewController.m
//  DotaAsker
//
//  Created by Artem on 07/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "AuthorizationViewController.h"
#import "ServiceLayer.h"
#import "SignInViewController.h"
#import "Palette.h"

@interface AuthorizationViewController ()

@end

@implementation AuthorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    [[self navigationController] setNavigationBarHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    self.username = [defaults valueForKey:@"username"];
    self.password = [defaults valueForKey:@"password"];
    if ((self.username != nil) && (self.password != nil)) {
        [self performSegueWithIdentifier:@"signin" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"signin"]) {
        if ((self.username != nil) && (self.password != nil)) {
            SignInViewController* destVC = [segue destinationViewController];
            [destVC setStrUsername:self.username];
            [destVC setStrPassword:self.password];
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
