//
//  MainViewController.m
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

// Local
#import "MainViewController.h"
#import "MatchViewController.h"
#import "StatisticsViewController.h"
#import "MainViewModel.h"
#import "ServiceLayer.h"
#import "Helper.h"
#import "Palette.h"
#import "ModalLoadingView.h"
#import "SignInViewController.h"

// Libraries
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>

@import CoreGraphics;

#define SECTION_PLAYER_INFO 0
#define SECTION_FIND_BUTTON 1
#define SECTION_CURRENT_MATCHES 2
#define SECTION_WAITING_MATCHES 3
#define SECTION_RECENT_MATCHES 4
#define SECTIONS_COUNT 5

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize viewModel = _viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    _viewModel = [[MainViewModel alloc] init];
    //add refresher controll
    self.tableView.refreshControl = [[UIRefreshControl alloc] init];
}

- (void)refreshControllDragged {   
    // Present LoadingView
    __block ModalLoadingView* loadingView = [[ModalLoadingView alloc] initWithMessage:NSLocalizedString(@"Updating player", 0)];
    [[[UIApplication sharedApplication] keyWindow] addSubview:loadingView];
    
    void (^errorBlock)(NSError* _Nonnull error) = ^void(NSError* _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentAlertControllerWithMessage:[error localizedDescription]];
            [loadingView removeFromSuperview];
        });
    };
    
    void (^completeBlock)() = ^void() {
        // UserAnswers has been updated.
        // Updaing Player and tableView
        RACReplaySubject* subject = [[[ServiceLayer instance] userService] obtainWithAccessToken:[[[ServiceLayer instance] authorizationService] accessToken]];
        [subject subscribeNext:^(id u) {
            [Player manualUpdate:u];
        } error:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadingView removeFromSuperview];
                [self.tableView.refreshControl endRefreshing];
            });
        } completed:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.tableView.refreshControl endRefreshing];
                [loadingView removeFromSuperview];
            });
        }];
    };

    [Player synchronizeWithErrorBlock:errorBlock completionBlock:completeBlock];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self loadBackgroundImage];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.tableView.refreshControl setTintColor:[UIColor whiteColor]];
    [self.tableView.refreshControl addTarget:self action:@selector(refreshControllDragged) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear: (BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideLoadingViewIfPresented];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == SECTION_PLAYER_INFO) {
        return 1;
    }
    else if(section == SECTION_FIND_BUTTON) {
        return 1;
    }
    //current matches
    else if (section == SECTION_CURRENT_MATCHES) {
        return [_viewModel currentMatchesCount];
    }
    //current matches
    else if (section == SECTION_WAITING_MATCHES) {
        return [_viewModel waitingMatchesCount];
    }
    //recent matches
    else if (section == SECTION_RECENT_MATCHES) {
        return [_viewModel recentMatchesCount];
    }
    else return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SECTIONS_COUNT;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    static NSString *PlayerInfoCellIdentifier = @"player_info_cell";
    static NSString *FindMatchCellIdentifier = @"find_match_cell";
    static NSString *MatchCellIdentifier = @"match_cell";
    
    if ([indexPath section] == SECTION_PLAYER_INFO) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:PlayerInfoCellIdentifier];
        UIImageView *playerImageView = (UIImageView*)[cell viewWithTag:200];
        [playerImageView setImage: [UIImage imageNamed:[[Player instance] avatarImageName]]];
        UILabel* playerNameLabel = (UILabel*)[cell viewWithTag:201];
        [playerNameLabel setText: [[Player instance] name]];
        [playerNameLabel setAdjustsFontSizeToFitWidth:YES];
        UILabel *mmrLabel = (UILabel*)[cell viewWithTag:202];
        [mmrLabel setText:[NSString stringWithFormat:NSLocalizedString(@"MMR: %ld", 0), (long)[[Player instance] MMR]]];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        [cell setSeparatorInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, cell.bounds.size.width)];
    }
    else if ([indexPath section] == SECTION_FIND_BUTTON) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:FindMatchCellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        [cell setSeparatorInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, cell.bounds.size.width)];
    }
    else if (([indexPath section] == SECTION_CURRENT_MATCHES) || ([indexPath section] == SECTION_RECENT_MATCHES) || ([indexPath section] == SECTION_WAITING_MATCHES)) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:MatchCellIdentifier];
    }
    
    //filling up with user's data
    if(cell) {
        if([indexPath section] == SECTION_CURRENT_MATCHES) {
            //opponent avatar
            UIImageView *avatarView = (UIImageView*)[cell viewWithTag:100];
            UILabel *matchStateLabel = (UILabel*)[cell viewWithTag:101];
            [matchStateLabel setText:[_viewModel matchStateTextForCurrentMatch:[indexPath row]]];
            UIImage *avatar = [UIImage imageNamed:[[_viewModel opponentForCurrentMatch:[indexPath row]] avatarImageName]];
            [avatarView setImage:avatar];
            //opponent name
            UILabel *nameLabel = (UILabel*)[cell viewWithTag:103];
            [nameLabel setText:[[_viewModel opponentForCurrentMatch:[indexPath row]] name]];
            [nameLabel setAdjustsFontSizeToFitWidth:YES];
            // mmr gain label
            UILabel* mmrGainLabel = (UILabel*)[cell viewWithTag:104];
            [mmrGainLabel setHidden:YES];
            // fight image view
            UIImageView* fightImageView = (UIImageView*)[cell viewWithTag:105];
            [fightImageView setHidden:NO];
        }
        else if([indexPath section] == SECTION_RECENT_MATCHES) {
            //opponent avatar
            UIImageView *avatarView = (UIImageView*)[cell viewWithTag:100];
            UILabel *matchStateLabel = (UILabel*)[cell viewWithTag:101];
            [matchStateLabel setText:[_viewModel matchStateTextForRecentMatch:[indexPath row]]];
            
            UIImage *avatar = [UIImage imageNamed:[[_viewModel opponentForRecentMatch:[indexPath row]] avatarImageName]];
            [avatarView setImage:avatar];
            //opponent name
            UILabel *nameLabel = (UILabel*)[cell viewWithTag:103];
            [nameLabel setText:[[_viewModel opponentForRecentMatch:[indexPath row]] name]];
            [nameLabel setAdjustsFontSizeToFitWidth:YES];
            // mmr gain label
            UILabel* mmrGainLabel = (UILabel*)[cell viewWithTag:104];
            
            Winner winner = [_viewModel winnerAtMatchAtRow:[indexPath row]];
            
            NSUInteger mmrGain = [_viewModel mmrGainForRecentMatchAtRow:[indexPath row]];
            NSString* mmrGainText = [NSString stringWithFormat:@"%@%ld", winner == kPlayer? @"+" : winner == kOpponent? @"-" : @"", mmrGain];
            UIColor* mmrGainTextColor = winner == kPlayer ? [UIColor greenColor] : winner == kOpponent ? [UIColor redColor] : [UIColor whiteColor];
            [mmrGainLabel setText:mmrGainText];
            [mmrGainLabel setTextColor:mmrGainTextColor];
            [mmrGainLabel setHidden:NO];
            // fight image view
            UIImageView* fightImageView = (UIImageView*)[cell viewWithTag:105];
            [fightImageView setHidden:YES];
        }
        else if([indexPath section] == SECTION_WAITING_MATCHES) {
            //opponent avatar
            UIImageView *avatarView = (UIImageView*)[cell viewWithTag:100];
            UILabel *matchStateLabel = (UILabel*)[cell viewWithTag:101];
            [matchStateLabel setText:[_viewModel matchStateTextForWaitingMatch:[indexPath row]]];
            
            UIImage *avatar = [UIImage imageNamed:[[_viewModel opponentForWaitingMatch:[indexPath row]] avatarImageName]];
            [avatarView setImage:avatar];
            //opponent name
            UILabel *nameLabel = (UILabel*)[cell viewWithTag:103];
            [nameLabel setText:[[_viewModel opponentForWaitingMatch:[indexPath row]] name]];
            [nameLabel setAdjustsFontSizeToFitWidth:YES];
            // mmr gain label
            UILabel* mmrGainLabel = (UILabel*)[cell viewWithTag:104];
            [mmrGainLabel setHidden:YES];
            // fight image view
            UIImageView* fightImageView = (UIImageView*)[cell viewWithTag:105];
            [fightImageView setHidden:YES];
        }
    }
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SECTION_CURRENT_MATCHES) {
        return NSLocalizedString(@"Current matches:", 0);
    }
    else if (section == SECTION_RECENT_MATCHES) {
        return NSLocalizedString(@"Recent matches:", 0);
    }
    else if (section == SECTION_WAITING_MATCHES) {
        return NSLocalizedString(@"Waiting matches:", 0);
    }
    else return NSLocalizedString(@"Error", 0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SECTION_PLAYER_INFO:
            return 0.0f;
            break;
        case SECTION_FIND_BUTTON:
            return 0.0f;
            break;
        case SECTION_CURRENT_MATCHES:
        {
            if ([[_viewModel currentMatches] count] != 0)
                return UITableViewAutomaticDimension;
            else
                return 0.0f;
        }
            break;
        case SECTION_WAITING_MATCHES:
        {
            if ([[_viewModel waitingMatches] count] != 0)
                return UITableViewAutomaticDimension;
            else
                return 0.0f;
        }
            break;
        case SECTION_RECENT_MATCHES:
        {
            if ([[_viewModel recentMatches] count] != 0)
                return UITableViewAutomaticDimension;
            else
                return 0.0f;
        }
        default:
            return 0.0f;
            break;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ((section == SECTION_PLAYER_INFO)||(section == SECTION_FIND_BUTTON)) {
        UIView *headerView = [[UIView alloc] init];
        headerView.backgroundColor = [UIColor clearColor];
        return headerView;
    }
    else {
        UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
        
        // 2. Set a custom background color and a border
        headerView.backgroundColor = [[Palette shared] statusBarColor];
        headerView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
        headerView.layer.borderWidth = 1.0;
        
        // 3. Add a label
        UILabel* headerLabel = [[UILabel alloc] init];
        [headerLabel setAdjustsFontSizeToFitWidth:YES];
        [headerLabel setFont:[UIFont fontWithName:@"Trajan Pro 3" size:12.0f]];
        headerLabel.frame = CGRectMake(5, 2, tableView.frame.size.width - 5, 18);
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = [UIColor whiteColor];
        if (section == SECTION_CURRENT_MATCHES) {
            headerLabel.text = NSLocalizedString(@"Current matches:", 0);
        }
        else if (section == SECTION_RECENT_MATCHES) {
            headerLabel.text = NSLocalizedString(@"Recent matches:", 0);
        }
        else if (section == SECTION_WAITING_MATCHES) {
            headerLabel.text = NSLocalizedString(@"Waiting matches:", 0);
        }
        headerLabel.textAlignment = NSTextAlignmentLeft;
        
        // 4. Add the label to the header view
        [headerView addSubview:headerLabel];
        
        // 5. Finally return
        return headerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        default:
            return 80;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showMatch"]) {
        MatchViewController *destVC = (MatchViewController*)[segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if ([indexPath section] == SECTION_CURRENT_MATCHES) {
            destVC.matchID = [[_viewModel currentMatchAtRow:[indexPath row]] ID];
        }
        else if ([indexPath section] == SECTION_RECENT_MATCHES) {
            destVC.matchID = [[_viewModel recentMatchAtRow:[indexPath row]] ID];
        }
        else if ([indexPath section] == SECTION_WAITING_MATCHES) {
            destVC.matchID = [[_viewModel waitingMatchAtRow:[indexPath row]] ID];
        }
    }
    else if ([[segue identifier] isEqualToString:@"statistics"]) {
        StatisticsViewController* destVC = [segue destinationViewController];
        [destVC setStatistic:sender];
    }
}

- (IBAction)findMatchPressed {
    ModalLoadingView* loadingView = [[ModalLoadingView alloc] initWithMessage:NSLocalizedString(@"Finding match", 0)];
    [[[UIApplication sharedApplication] keyWindow] addSubview:loadingView];
    
    RACSignal* signal = [[[ServiceLayer instance] matchService] findMatchForUser:[[[ServiceLayer instance] authorizationService] accessToken]];
    [signal subscribeNext:^(id x) {
        // add match
        [Player manualAddMatch: x];
        [loadingView removeFromSuperview];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [loadingView removeFromSuperview];
        [self presentAlertControllerWithMessage:[error localizedDescription]];
    }];
}

- (IBAction)showStatistics {
    if ([self checkPremium]) {
        ModalLoadingView* loadingView = [[ModalLoadingView alloc] initWithMessage:NSLocalizedString(@"Getting statistics", 0)];
        [[[UIApplication sharedApplication] keyWindow] addSubview:loadingView];
        
        RACReplaySubject* subject = [[[ServiceLayer instance] userService] obtainStatistic:[Player instance].ID];
        [subject subscribeNext:^(id x) {
            NSDictionary* statistics = x;
            [loadingView removeFromSuperview];
            [self performSegueWithIdentifier:@"statistics" sender:statistics];
        } error:^(NSError *error) {
            [loadingView removeFromSuperview];
        } completed:^{  
        }];
    }
    else {
        [self presentAlertControllerWithMessage:NSLocalizedString(@"Premium account only", 0)];
    }
}

- (IBAction)logout {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"username"];
    [defaults removeObjectForKey:@"password"];
    SignInViewController* destVC = (SignInViewController*)[[[self navigationController] viewControllers] objectAtIndex:[[[self navigationController] viewControllers] count] - 2];
    
    [destVC setStrUsername:@""];
    [destVC setStrPassword:@""];
    [[self navigationController] popViewControllerAnimated:YES];
    
}

- (IBAction)settings:(id)sender {
    [self performSegueWithIdentifier:@"settings" sender:self];
}

- (BOOL)checkPremium {
    if (![[Player instance] premium]) {
        return NO;
    }
    else
        return YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Getting player info stack view
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    // Getting sizes
    UILabel* playerNameLabel = (UILabel*)[cell viewWithTag:201];
    float stringWidth = [playerNameLabel intrinsicContentSize].width;
    float iconWidth = [cell viewWithTag:200].bounds.size.width;
    float screenWidth = self.view.frame.size.width;
    float spacing = 14;
    float constraintWidth = (screenWidth - iconWidth - stringWidth - spacing) / 2.0f;
        
    // [2] Updating constraints
    NSLayoutConstraint* leading;
    NSLayoutConstraint* trailing;
    UIStackView* playerStackView = [cell viewWithTag:206];
    for (NSLayoutConstraint* con in self.tableView.constraints) {
        if (con.secondItem == playerStackView)
            if (con.secondAttribute == NSLayoutAttributeLeading)
                leading = con;
            else if (con.secondAttribute == NSLayoutAttributeTrailing)
                trailing = con;
            else
                continue;
        else
            continue;
    }
    
    if (!leading) {
        [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                                        attribute:NSLayoutAttributeLeading
                                                                        relatedBy:NSLayoutRelationEqual
                                                                            toItem:playerStackView
                                                                        attribute:NSLayoutAttributeLeading
                                                                        multiplier:1.0
                                                                        constant:-constraintWidth]];
    }
    else {
        [leading setConstant:-constraintWidth];
    }
    if (!trailing) {
        [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:playerStackView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.tableView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        multiplier:1.0
                                                                        constant:constraintWidth]];
    }
    else {
        [trailing setConstant:constraintWidth];
    }
}

@end
