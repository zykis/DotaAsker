//
//  UnlockPremiumViewController.m
//  DotaAsker
//
//  Created by Artem on 24/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "UnlockPremiumViewController.h"
#import "ServiceLayer.h"
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>

@interface UnlockPremiumViewController ()

@end

@implementation UnlockPremiumViewController

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
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
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
    
   RLMRealm* realm = [RLMRealm defaultRealm];
   [realm beginWriteTransaction];
   [[Player instance] setPremium:YES];
   [realm commitWriteTransaction];
   
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
