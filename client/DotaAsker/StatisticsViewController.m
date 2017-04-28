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

@synthesize statistic = _statistic;
@synthesize chartView = _chartView;
@synthesize pieChartView = _pieChartView;
@synthesize contentView = _contentView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    [self loadBackgroundImageForView:_contentView];
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
    _chartView.noDataText = NSLocalizedString("Not enough data for displaying statistic (Need at least 1 day after registration)", 0);
    
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
    
    NSMutableArray<BarChartDataEntry*>* entries = [[NSMutableArray alloc] init];
    NSUInteger minStats = MIN([[_statistic allKeys] count], 7);
    for (int i = 0; i < minStats; i++) {
        BarChartDataEntry* entry = [[BarChartDataEntry alloc] init];
        [entry setX:i];
        NSString* key = [[_statistic allKeys] objectAtIndex:i];
        NSString* dateString = key;
        [entry setData:dateString];
        [entry setY:[[_statistic objectForKey:key] integerValue]];
        [entries addObject:entry];
    }

    if (minStats >= 2) {
        BarChartDataSet* dataSet = [[BarChartDataSet alloc] initWithValues:entries];
        dataSet.barShadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.15];
        dataSet.barBorderWidth = 0.8f;
        dataSet.barBorderColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        dataSet.highlightAlpha = 0.15f;
        dataSet.valueFont = [UIFont fontWithName:@"Trajan Pro 3" size:9];
        [dataSet setColors:@[[[Palette shared] themesButtonColor]]];
        dataSet.valueTextColor = [UIColor whiteColor];
        dataSet.label = @"MMR";
        
        BarChartData* data = [[BarChartData alloc] initWithDataSet:dataSet];
        _chartView.data = data;
    }
    
    // Pie Chart
    _pieChartView.holeRadiusPercent = 0.25f;
    _pieChartView.descriptionText = @"";
    _pieChartView.legend.enabled = NO;
    _pieChartView.backgroundColor = [UIColor clearColor];
    _pieChartView.tintColor = [UIColor brownColor];
    _pieChartView.highlightPerTapEnabled = NO;
    UIColor* patternColor = [UIColor colorWithPatternImage:[[Palette shared] pattern]];
    _pieChartView.transparentCircleColor = [UIColor clearColor];
    _pieChartView.transparentCircleRadiusPercent = 0.0f;
    _pieChartView.holeColor = patternColor;
    _pieChartView.rotationEnabled = NO;
    _pieChartView.rotationAngle = 30;
    _pieChartView.noDataText = NSLocalizedString("Not enough data for displaying statistic (Need at least 1 matches finished)", 0);
    
    NSUInteger totalMatches = [[Player instance] totalMatchesWon] + [[Player instance] totalMatchesLost];
    if (totalMatches > 0) {
        float winRate = (float)[[Player instance] totalMatchesWon] / (float)totalMatches;
        float winPercent = winRate * 100;
        float losePercent = (1 - winRate) * 100;
        
        NSMutableArray *entriesArray = [[NSMutableArray alloc] init];
        if (winPercent > 0) {
            PieChartDataEntry* eWin = [[PieChartDataEntry alloc] initWithValue:winPercent];
            eWin.label = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Won", 0)];
            [entriesArray addObject:eWin];
        }
        if (losePercent > 0) {
            PieChartDataEntry* eLose = [[PieChartDataEntry alloc] initWithValue:losePercent];
            eLose.label = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Lost", 0)];
            [entriesArray addObject:eLose];
        }
        
        PieChartDataSet* dSet = [[PieChartDataSet alloc] initWithValues:[NSArray arrayWithArray:entriesArray]];
        dSet.valueLinePart1OffsetPercentage = 10.0f;
        NSMutableArray* colorsArray = [[NSMutableArray alloc] init];
        if (winPercent > 0) {
            [colorsArray addObject:[[[Palette shared] darkGreenColor] colorWithAlphaComponent:1.0]];
        }
        if (losePercent > 0) {
            [colorsArray addObject:[[[Palette shared] darkRedColor] colorWithAlphaComponent:1.0]];
        }
        dSet.sliceSpace = 4;
        dSet.valueFormatter = (id)[[PercentValueFormatter alloc] init];
        dSet.selectionShift = 0.0f;
        dSet.colors = [NSArray arrayWithArray:colorsArray];
        dSet.entryLabelFont = [UIFont fontWithName:@"Trajan Pro 3" size:11.0];
        dSet.valueFont = [UIFont fontWithName:@"Trajan Pro 3" size:16.0];
        PieChartData* d = [[PieChartData alloc] initWithDataSet:dSet];
        _pieChartView.data = d;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[Match objectsWhere:[NSString stringWithFormat:@"state == %d", MATCH_FINISHED]] count];
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
    [mmrGain setTextColor: winner == kPlayer ? [UIColor greenColor] : winner == kOpponent ? [UIColor redColor] : [UIColor whiteColor]];
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
