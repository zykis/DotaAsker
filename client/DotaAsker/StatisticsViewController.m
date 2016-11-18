//
//  StatisticsViewController.m
//  DotaAsker
//
//  Created by Artem on 15/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "StatisticsViewController.h"
#import "ServiceLayer.h"
#import "LoadingView.h"

#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>

@interface StatisticsViewController ()

@end

@implementation StatisticsViewController

@synthesize user = _user;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.userID) {
        NSLog(@"No user specified");
        [[self navigationController] popViewControllerAnimated:YES];
    }
    
    LoadingView* loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50)];
    [loadingView setMessage:@"Getting player"];
    [[self view] addSubview:loadingView];
    
    RACReplaySubject* subject = [[[ServiceLayer instance] userService] obtain:self.userID];
    [subject subscribeNext:^(id x) {
        _user = x;
    } error:^(NSError *error) {
        NSLog(@"Error retrieving user: %llu", self.userID);
        NSLog(@"%@", [error localizedDescription]);
        [loadingView removeFromSuperview];
        [[self navigationController] popViewControllerAnimated:YES];
    } completed:^{
        [loadingView removeFromSuperview];
        [self fillUser];
    }];
}

- (void)fillUser {
    [self.mmr setText: [NSString stringWithFormat:@"%lu", [_user MMR]]];
    [self.kda setText: [NSString stringWithFormat:@"%.2f", [_user KDA]]];
    [self.gpm setText: [NSString stringWithFormat:@"%.2f", [_user GPM]]];
    
    float averageAnswerTime = 0;
    if (_user.totalCorrectAnswers + _user.totalIncorrectAnswers)
        averageAnswerTime = _user.totalTimeForAnswers / (_user.totalCorrectAnswers + (float)_user.totalIncorrectAnswers);
    [self.answerTime setText: [NSString stringWithFormat:@"%.2f", averageAnswerTime]];
    
    if (_user.totalIncorrectAnswers)
        [self.averageCorrectAnswers setText:[NSString stringWithFormat:@"%.2f%%", (_user.totalCorrectAnswers / (float)_user.totalIncorrectAnswers)]];
    else
        [self.averageCorrectAnswers setText:@"1.00"];
    
    [self.wins setText:[NSString stringWithFormat:@"%lu", _user.totalMatchesWon]];
    [self.lost setText:[NSString stringWithFormat:@"%lu", _user.totalMatchesLost]];
    
    [self.avatar setImage:[UIImage imageNamed:[_user avatarImageName]]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
