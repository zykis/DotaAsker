//
//  StatisticsViewController.m
//  DotaAsker
//
//  Created by Artem on 15/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

// Local
#import "StatisticsViewController.h"
#import "ServiceLayer.h"
#import "ModalLoadingView.h"
#import "Palette.h"

// Libraries
#import <Charts/Charts-Swift.h>
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>

@interface StatisticsViewController ()

@end

@implementation StatisticsViewController

@synthesize chartView = _chartView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    [self fillUser];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.backgroundColor = [UIColor clearColor];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    _tableView.layer.cornerRadius = 4;
}

- (void)fillUser {
    User* user = [Player instance];
    [self.navigationTitle setTitle:[user name]];
    [self.mmr setText: [NSString stringWithFormat:@"%ld", (long)[user MMR]]];
    
    float averageAnswerTime = 0;
    if (user.totalCorrectAnswers + user.totalIncorrectAnswers)
        averageAnswerTime = user.totalTimeForAnswers / (user.totalCorrectAnswers + (float)user.totalIncorrectAnswers);
    
    [self.wins setText:[NSString stringWithFormat:@"%ld", (long)user.totalMatchesWon]];
    [self.lost setText:[NSString stringWithFormat:@"%ld", (long)user.totalMatchesLost]];
    
    [self.avatar setImage:[UIImage imageNamed:[user avatarImageName]]];
    [self.tableView reloadData];
    
    // Chart
    _chartView.layer.cornerRadius = 4;
    _chartView.chartDescription.enabled = YES;
    _chartView.highlightPerTapEnabled = YES;
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.drawBordersEnabled = NO;
    _chartView.backgroundColor = [[Palette shared] themesButtonColor];
    
    ChartXAxis* xaxis = _chartView.xAxis;
    xaxis.drawGridLinesEnabled = NO;
    xaxis.drawAxisLineEnabled = NO;
    xaxis.drawLabelsEnabled = NO;
    
    ChartYAxis* laxis = _chartView.leftAxis;
    laxis.drawGridLinesEnabled = NO;
    laxis.drawAxisLineEnabled = NO;
    laxis.drawLabelsEnabled = NO;
    
    ChartYAxis* raxis = _chartView.rightAxis;
    raxis.drawGridLinesEnabled = NO;
    raxis.drawAxisLineEnabled = NO;
    raxis.drawLabelsEnabled = NO;
    
    NSMutableArray<ChartDataEntry*>* entries = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i++) {
        ChartDataEntry* entry = [[ChartDataEntry alloc] init];
        [entry setX:i];
        [entry setY:(float)rand() / RAND_MAX * 5000 + 4000];
        [entries addObject:entry];
    }

    LineChartDataSet* dataSet = [[LineChartDataSet alloc] initWithValues:entries];
    dataSet.circleHoleRadius = 2.0f;
    dataSet.circleRadius = 4.0f;
    dataSet.circleColors = @[[[Palette shared] backgroundColor]];
    dataSet.circleHoleColor = [[Palette shared] themesButtonColor];
    dataSet.drawCubicEnabled = YES;
    dataSet.drawFilledEnabled = YES;
    dataSet.valueTextColor = [[Palette shared] backgroundColor];
    
    LineChartData* data = [[LineChartData alloc] initWithDataSet:dataSet];
    _chartView.data = data;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[Player instance] matches] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"match"];
    Match* m = [[[Player instance] matches] objectAtIndex:[indexPath row]];
    UILabel* opponentName = [cell viewWithTag:100];
    UIImageView* opponentAvatar = [cell viewWithTag:101];
    UILabel* score = [cell viewWithTag:102];
    UILabel* mmrGain = [cell viewWithTag:103];
    
    User* opponent = [[User alloc] init];
    
    for (User* u in [m users]) {
        if (![u isEqual:[Player instance]])
            opponent = u;
    }
    
    // name
    [opponentName setText:[opponent name]];
    // avatar
    [opponentAvatar setImage:[UIImage imageNamed:[opponent avatarImageName]]];
    // score
    NSUInteger scorePlayer = [[[ServiceLayer instance] matchService] scoreForMatch:m andUser:[Player instance]];
    NSUInteger scoreOpponent = [[[ServiceLayer instance] matchService] scoreForMatch:m andUser:opponent];
    NSString* scoreStr = [NSString stringWithFormat:@"%lu - %lu", (unsigned long)scorePlayer, (unsigned long)scoreOpponent];
    [score setText:scoreStr];
    // mmr gain
    User* winner;
    if (scorePlayer > scoreOpponent)
        winner = [Player instance];
    else
        winner = opponent;
    BOOL userWinner = [winner isEqual:[Player instance]];
    [mmrGain setTextColor: userWinner? [UIColor greenColor]: [UIColor redColor]];
    [mmrGain setText:[NSString stringWithFormat:@"%@%lu", userWinner? @"+": @"-" ,(long)[m mmrGain]]];
    
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
