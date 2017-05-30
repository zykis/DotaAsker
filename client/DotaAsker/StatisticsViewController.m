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
#import "DateAxisValueFormatter.h"

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
    self.backgroundView.layer.backgroundColor = [[Palette shared] backgroundColor].CGColor;
    self.backgroundView.layer.cornerRadius = 8;
    
    [self fillUser];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.backgroundColor = [UIColor clearColor];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    _tableView.layer.cornerRadius = 8;
}

- (void)fillUser {
    User* user = [Player instance];
    [self.labelUsername setText:[user name]];
    [self.mmr setText: [NSString stringWithFormat:@"%ld", (long)[user MMR]]];
    [self.labelWon setText:[NSString stringWithFormat:@"%ld", (long)[user totalMatchesWon]]];
    [self.labelLost setText:[NSString stringWithFormat:@"%ld", (long)[user totalMatchesLost]]];
    [self.labelGPM setText:[NSString stringWithFormat:@"%.1f", [user GPM]]];
    [self.labelKDA setText:[NSString stringWithFormat:@"%.1f", [user KDA]]];
    [self.avatar setImage:[UIImage imageNamed:[user avatarImageName]]];
    
    float averageAnswerTime = 0;
    if (user.totalCorrectAnswers + user.totalIncorrectAnswers)
        averageAnswerTime = user.totalTimeForAnswers / (user.totalCorrectAnswers + (float)user.totalIncorrectAnswers);
    [self.tableView reloadData];
    
    // Chart
    _chartView.chartDescription.enabled = YES;
    _chartView.highlightPerTapEnabled = YES;
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.drawBordersEnabled = NO;
    _chartView.backgroundColor = [[Palette shared] backgroundColor];
    _chartView.descriptionText = @"";
    _chartView.legend.enabled = NO;
    _chartView.scaleXEnabled = NO;
    _chartView.scaleYEnabled = NO;
    _chartView.noDataText = NSLocalizedString(@"Not enough data for displaying statistic (Need at least a day after registration)", 0);
    _chartView.noDataTextColor = [UIColor whiteColor];
    _chartView.layer.cornerRadius = 8.0f;
    _chartView.layer.masksToBounds = YES;
   
    
    ChartXAxis* xaxis = _chartView.xAxis;
    DateAxisValueFormatter* dateFormatter = [[DateAxisValueFormatter alloc] init];
    xaxis.drawGridLinesEnabled = YES;
    xaxis.drawAxisLineEnabled = YES;
    xaxis.drawLabelsEnabled = YES;
    xaxis.labelPosition = XAxisLabelPositionBottom;
    xaxis.labelTextColor = [UIColor whiteColor];
    xaxis.valueFormatter = dateFormatter;
    xaxis.labelFont = [UIFont systemFontOfSize:7];
    // xaxis.granularity = 60.0 * 60 * 24;
    // xaxis.granularityEnabled = YES;
    // xaxis.avoidFirstLastClippingEnabled = YES;
    xaxis.forceLabelsEnabled = YES;
    xaxis.centerAxisLabelsEnabled = YES;
    
    ChartYAxis* laxis = _chartView.leftAxis;
    laxis.drawGridLinesEnabled = YES;
    laxis.drawAxisLineEnabled = YES;
    laxis.drawLabelsEnabled = YES;
    laxis.labelTextColor = [UIColor whiteColor];
    laxis.granularity = 5;
    laxis.granularityEnabled = YES;
    
    ChartYAxis* raxis = _chartView.rightAxis;
    raxis.drawGridLinesEnabled = YES;
    raxis.drawAxisLineEnabled = NO;
    raxis.drawLabelsEnabled = NO;
    
    NSMutableArray<BarChartDataEntry*>* entries = [[NSMutableArray alloc] init];
    // _statistic may contain up to 30 values, so let's restict this to 7 for a week
    NSUInteger minStats = MIN([[_statistic allKeys] count], 7);
    NSUInteger lastIndex = [[_statistic allKeys] count] - 1;
    NSUInteger count = minStats;
    NSArray* statisticsOrderedKeys = [[_statistic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString* string1 = (NSString*)obj1;
        NSString* string2 = (NSString*)obj2;
        long int1 = [[string1 stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
        long int2 = [[string2 stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
        return int1 < int2 ? NSOrderedAscending: int1 == int2 ? NSOrderedSame: NSOrderedDescending;
    }];
    NSArray* weekStatisticsKeys = [statisticsOrderedKeys objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(lastIndex - count + 1, count)]];
    NSMutableDictionary* weekStatistics = [[NSMutableDictionary alloc] init];
    for (NSString* key in weekStatisticsKeys) {
        weekStatistics[key] = [_statistic objectForKey:key];
    }
    
    for (int i = 0; i < minStats; i++) {
        BarChartDataEntry* entry = [[BarChartDataEntry alloc] init];
        
        NSString* key = [[weekStatistics allKeys] objectAtIndex:i];
        
        NSDateFormatter *fromFormatter = [[NSDateFormatter alloc] init];
        [fromFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate* date = [fromFormatter dateFromString:key];
        
        double ti = [date timeIntervalSince1970];
        
        [entry setX:ti];
        [entry setY:[[_statistic objectForKey:key] integerValue]];
        [entries addObject:entry];
    }
    
    if (minStats >= 1) {
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
        
        double xMin = [dataSet xMin];
        double xMax = [dataSet xMax];
        double w = MAX(1, xMax - xMin); // width of x-axis in seconds
        double spacing = 0.05; // 5% of barWidth
        double barWidth = w / [dataSet values].count - (spacing * w / ([dataSet values].count + 1));
        data.barWidth = barWidth;
        [_chartView setFitBars:YES];
        
        xaxis.spaceMin = barWidth / 10.0;
        xaxis.spaceMax = barWidth / 10.0;
        xaxis.xOffset = barWidth;
        
        _chartView.data = data;
    }
    [xaxis setLabelCount:minStats force:YES];
    
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
    _pieChartView.noDataText = NSLocalizedString(@"Not enough data for displaying statistic (Need at least 1 matches finished)", 0);
    _pieChartView.noDataTextColor = [UIColor whiteColor];
    
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
        dSet.entryLabelFont = [UIFont fontWithName:@"Trajan Pro 3" size:8.0];
        dSet.valueFont = [UIFont fontWithName:@"Trajan Pro 3" size:11.0];
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
