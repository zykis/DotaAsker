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
#import "PercentValueFormatter.h"

// Libraries
#import <Charts/Charts-Swift.h>
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>


@interface StatisticsViewController ()

@end

@implementation StatisticsViewController

@synthesize chartView = _chartView;
@synthesize pieChartView = _pieChartView;

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
    
    [self.avatar setImage:[UIImage imageNamed:[user avatarImageName]]];
    [self.tableView reloadData];
    
    // Chart
    _chartView.layer.cornerRadius = 4;
    _chartView.chartDescription.enabled = YES;
    _chartView.highlightPerTapEnabled = YES;
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.drawBordersEnabled = NO;
    _chartView.backgroundColor = [UIColor clearColor];
    _chartView.descriptionText = @"";
    _chartView.legend.enabled = NO;
    _chartView.scaleXEnabled = NO;
    _chartView.scaleYEnabled = NO;
    
    ChartXAxis* xaxis = _chartView.xAxis;
    xaxis.drawGridLinesEnabled = NO;
    xaxis.drawAxisLineEnabled = YES;
    xaxis.drawLabelsEnabled = YES;
    xaxis.labelPosition = XAxisLabelPositionBottom;
    xaxis.labelTextColor = [UIColor whiteColor];
    
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
        NSString* dateString = @"12.04";
        [entry setData:dateString];
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
    dataSet.valueTextColor = [[Palette shared] themesButtonColor];
    dataSet.fillColor = [UIColor greenColor];
    dataSet.label = @"MMR";
    
    LineChartData* data = [[LineChartData alloc] initWithDataSet:dataSet];
    _chartView.data = data;
    
    // Pie Chart
    _pieChartView.holeRadiusPercent = 0.15f;
    _pieChartView.descriptionText = @"";
    _pieChartView.legend.enabled = NO;
    _pieChartView.backgroundColor = [UIColor clearColor];
    _pieChartView.tintColor = [UIColor brownColor];
    _pieChartView.highlightPerTapEnabled = NO;
    _pieChartView.transparentCircleColor = [UIColor clearColor];
    _pieChartView.holeColor = [UIColor whiteColor];
    
    float winRate = (float)[[Player instance] totalMatchesWon] / (float)([[Player instance] totalMatchesLost] + [[Player instance] totalMatchesWon]);
    PieChartDataEntry* eWin = [[PieChartDataEntry alloc] initWithValue:winRate * 100];
    eWin.label = @"Won";
    PieChartDataEntry* eLose = [[PieChartDataEntry alloc] initWithValue:(1 - winRate) * 100];
    eLose.label = @"Lost";
    
    PieChartDataSet* dSet = [[PieChartDataSet alloc] initWithValues:@[eLose, eWin]];
    dSet.sliceSpace = 4;
    dSet.valueFormatter = (id)[[PercentValueFormatter alloc] init];
    dSet.selectionShift = 0.0f;
    dSet.colors = @[[[[Palette shared] darkRedColor] colorWithAlphaComponent:0.7], [[[Palette shared] darkGreenColor] colorWithAlphaComponent:0.7]];
    PieChartData* d = [[PieChartData alloc] initWithDataSet:dSet];
    _pieChartView.data = d;
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

- (NSArray*)recentMatches {
    NSMutableArray* resultMatches = [[NSMutableArray alloc] init];
    
    for (Match* m in [Match allObjects]) {
        if (m.state == MATCH_FINISHED)
            [resultMatches addObject:m];
    }
    
    // Sorting array by updated date
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedOn" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    NSArray *sortedMatches = [resultMatches sortedArrayUsingDescriptors:sortDescriptors];
    
    return [NSArray arrayWithArray: sortedMatches];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"match"];
    
    Match* m = [[self recentMatches] objectAtIndex:[indexPath row]];
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
    Winner winner = [[[ServiceLayer instance] matchService] winnerAtMatch:m];
    [mmrGain setTextColor: winner == kPlayer ? [UIColor greenColor] : winner == kOpponent ? [UIColor redColor] : [UIColor grayColor]];
    [mmrGain setText:[NSString stringWithFormat:@"%@%lu", winner == kPlayer ? @"+" : winner == kOpponent ?  @"-" : @"" ,(long)[m mmrGain]]];
    
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
