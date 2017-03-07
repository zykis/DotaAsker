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

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (previousTraitCollection.horizontalSizeClass != self.traitCollection.horizontalSizeClass) {
        switch (self.traitCollection.horizontalSizeClass) {
            case UIUserInterfaceSizeClassRegular:
                [self setupRegularWidth];
                break;
                
            case UIUserInterfaceSizeClassCompact:
                [self setupCompactWidth];
                break;
                
            case UIUserInterfaceSizeClassUnspecified:
                NSLog(@"Weird size class");
                break;
                
            default:
                break;
        }
    }
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
}

- (IBAction)premiumPushed {
    [self performSegueWithIdentifier:@"unlock_premium" sender:self];
}

- (IBAction)top100Pushed {
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

- (void)setupCompactWidth {
    
}

- (void)setupRegularWidth {
    
}

@end
