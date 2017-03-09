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

#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>

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
    
    RACReplaySubject* subject = [[[ServiceLayer instance] userService] obtainStatistic:self.userID];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)fillUser {
    [self.navigationTitle setTitle:[_user name]];
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
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_user matches] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"match"];
    Match* m = [[_user matches] objectAtIndex:[indexPath row]];
    UILabel* opponentName = [cell viewWithTag:100];
    UIImageView* opponentAvatar = [cell viewWithTag:101];
    UILabel* score = [cell viewWithTag:102];
    UILabel* mmrGain = [cell viewWithTag:103];
    UILabel* date = [cell viewWithTag:104];
    
    User* opponent;
    
    for (User* u in [m users]) {
        if (![u isEqual:_user])
            opponent = u;
    }
    assert(opponent);
    
    // name
    [opponentName setText:[opponent name]];
    // avatar
    [opponentAvatar setImage:[UIImage imageNamed:[opponent avatarImageName]]];
    // score
    NSUInteger scorePlayer = [[[ServiceLayer instance] matchService] scoreForMatch:m andUser:_user];
    NSUInteger scoreOpponent = [[[ServiceLayer instance] matchService] scoreForMatch:m andUser:opponent];
    NSString* scoreStr = [NSString stringWithFormat:@"%lu - %lu", scorePlayer, scoreOpponent];
    [score setText:scoreStr];
    // mmr gain
    User* winner;
    if (scorePlayer > scoreOpponent)
        winner = _user;
    else
        winner = opponent;
    BOOL userWinner = [winner isEqual:_user];
    [mmrGain setTextColor: userWinner? [UIColor greenColor]: [UIColor redColor]];
    [mmrGain setText:[NSString stringWithFormat:@"%@%lu", userWinner? @"+": @"-" ,[m mmrGain]]];
    // date
    [date setText:[m updatedOn]];
    
    return cell;
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
