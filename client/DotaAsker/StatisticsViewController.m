//
//  StatisticsViewController.m
//  DotaAsker
//
//  Created by Artem on 15/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "StatisticsViewController.h"
#import "ServiceLayer.h"
#import "ModalLoadingView.h"

#import <Charts/Charts-Swift.h>
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>

@interface StatisticsViewController ()

@end

@implementation StatisticsViewController

@synthesize user = _user;
@synthesize chartView = _chartView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    
    if (!self.userID) {
        NSLog(@"No user specified");
        [[self navigationController] popViewControllerAnimated:YES];
    }
    
    ModalLoadingView* loadingView = [[ModalLoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50) andMessage:@"Getting player"];
    [[[UIApplication sharedApplication] keyWindow] addSubview:loadingView];
    
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
    self.tableView.backgroundColor = [UIColor clearColor];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)fillUser {
    [self.navigationTitle setTitle:[_user name]];
    [self.mmr setText: [NSString stringWithFormat:@"%ld", (long)[_user MMR]]];
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
    
    [self.wins setText:[NSString stringWithFormat:@"%ld", (long)_user.totalMatchesWon]];
    [self.lost setText:[NSString stringWithFormat:@"%ld", (long)_user.totalMatchesLost]];
    
    [self.avatar setImage:[UIImage imageNamed:[_user avatarImageName]]];
    [self.tableView reloadData];
    
    // Chart
    _chartView.usePercentValuesEnabled = YES;
    _chartView.drawSlicesUnderHoleEnabled = NO;
    _chartView.holeRadiusPercent = 0.58;
    _chartView.transparentCircleRadiusPercent = 0.61;
    _chartView.chartDescription.enabled = YES;
    
    _chartView.drawCenterTextEnabled = YES;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *centerText = [[NSMutableAttributedString alloc] initWithString:@"Charts\nby Daniel Cohen Gindi"];
    _chartView.centerAttributedText = centerText;
    
    _chartView.drawHoleEnabled = YES;
    _chartView.rotationAngle = 0.0;
    _chartView.rotationEnabled = YES;
    _chartView.highlightPerTapEnabled = YES;
    
    ChartLegend *l = _chartView.legend;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentRight;
    l.verticalAlignment = ChartLegendVerticalAlignmentTop;
    l.orientation = ChartLegendOrientationVertical;
    l.drawInside = NO;
    l.xEntrySpace = 7.0;
    l.yEntrySpace = 0.0;
    l.yOffset = 0.0;
    
    NSMutableArray<PieChartDataEntry*>* entries = [[NSMutableArray alloc] init];
    PieChartDataEntry* entry = [[PieChartDataEntry alloc] init];
    [entry setX:0.5];
    [entry setY:0.7];
    [entries addObject:entry];
    [entries addObject:entry];
    PieChartDataSet* dataSet = [[PieChartDataSet alloc] initWithValues:entries label:@"Label"];
    PieChartData* data = [[PieChartData alloc] initWithDataSet:dataSet];
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
    
    User* opponent = [[User alloc] init];
    
    for (User* u in [m users]) {
        if (![u isEqual:_user])
            opponent = u;
    }
    
    // name
    [opponentName setText:[opponent name]];
    // avatar
    [opponentAvatar setImage:[UIImage imageNamed:[opponent avatarImageName]]];
    // score
    NSUInteger scorePlayer = [[[ServiceLayer instance] matchService] scoreForMatch:m andUser:_user];
    NSUInteger scoreOpponent = [[[ServiceLayer instance] matchService] scoreForMatch:m andUser:opponent];
    NSString* scoreStr = [NSString stringWithFormat:@"%lu - %lu", (unsigned long)scorePlayer, (unsigned long)scoreOpponent];
    [score setText:scoreStr];
    // mmr gain
    User* winner;
    if (scorePlayer > scoreOpponent)
        winner = _user;
    else
        winner = opponent;
    BOOL userWinner = [winner isEqual:_user];
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
