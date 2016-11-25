//
//  UnlockPremiumViewController.m
//  DotaAsker
//
//  Created by Artem on 24/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "UnlockPremiumViewController.h"
#import "ServiceLayer.h"
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>

@interface UnlockPremiumViewController ()

@end

@implementation UnlockPremiumViewController

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
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
}

- (IBAction)backButtonPressed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)unlockPressed {
    NSLog(@"Unlocking premium");
    [[Player instance] setPremium:YES];
    RACReplaySubject* subject = [[[ServiceLayer instance] userService] update:[Player instance]];
    [subject subscribeNext:^(id x) {
        NSLog(@"Premium updated");
    } error:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    } completed:^{
        NSLog(@"Premium update complited");
    }];
}
@end
