//
//  MainViewController.m
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "MainViewController.h"
#import "MatchViewController.h"
#import "StatisticsViewController.h"
#import "MainViewModel.h"
#import "ServiceLayer.h"
#import "Helper.h"
#import "Palette.h"
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
    LoadingView* loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50)];
    [loadingView setMessage:@"Updating player"];
    [[self view] addSubview:loadingView];
    
    [[[[ServiceLayer instance] userService] obtainWithAccessToken:[[[ServiceLayer instance] authorizationService] accessToken]]
     subscribeNext:^(User* u) {
        RLMRealm* realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteAllObjects];
        [realm commitWriteTransaction];
        
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:u];
        [realm commitWriteTransaction];
        
        [Player setID: u.ID];
        [self.tableView reloadData];
        [self.tableView.refreshControl endRefreshing];
        [loadingView removeFromSuperview];
     } error:^(NSError *error) {
         [self.tableView.refreshControl endRefreshing];
         [loadingView removeFromSuperview];
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self loadBackgroundImage];
    [self loadBackgroundImage:[[Palette shared] pattern]  atView:self.tableView];
    
    [self.tableView.refreshControl setTintColor:[UIColor whiteColor]];
    [self.tableView.refreshControl addTarget:self action:@selector(refreshControllDragged) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
        [mmrLabel setText:[NSString stringWithFormat:@"MMR: %ld", (long)[[Player instance] MMR]]];
        UILabel *KDALabel = (UILabel*)[cell viewWithTag:203];
        [KDALabel setText:[NSString stringWithFormat:@"KDA: %.2f", (float)[[Player instance] KDA]]];
        UILabel *GPMLabel = (UILabel*)[cell viewWithTag:204];
        [GPMLabel setText:[NSString stringWithFormat:@"GPM: %.2f", (float)[[Player instance] GPM]]];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.0f];
        [cell setSeparatorInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, cell.bounds.size.width)];
    }
    else if ([indexPath section] == SECTION_FIND_BUTTON) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:FindMatchCellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.0f];
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
        }
    }
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SECTION_CURRENT_MATCHES) {
        return @"Current matches";
    }
    else if (section == SECTION_RECENT_MATCHES) {
        return @"Recent matches";
    }
    else if (section == SECTION_WAITING_MATCHES) {
        return @"Waiting matches";
    }
    else return @"Error";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == SECTION_PLAYER_INFO) {
        return 0.0f;
    }
    else if (section == SECTION_FIND_BUTTON) {
        return 0.0f;
    }
    else if ((section == SECTION_CURRENT_MATCHES) || (section == SECTION_RECENT_MATCHES) || (section == SECTION_WAITING_MATCHES)) {
        return UITableViewAutomaticDimension;
    }
    return 0;
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
        [headerLabel setFont:[UIFont fontWithName:@"TrajanBold" size:12.0f]];
        headerLabel.frame = CGRectMake(5, 2, tableView.frame.size.width - 5, 18);
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = [UIColor whiteColor];
        if (section == SECTION_CURRENT_MATCHES) {
            headerLabel.text = @"Current matches:";
        }
        else if (section == SECTION_RECENT_MATCHES) {
            headerLabel.text = @"Recent matches:";
        }
        else if (section == SECTION_WAITING_MATCHES) {
            headerLabel.text = @"Waiting matches:";
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
        [destVC setUserID:[[Player instance] ID]];
    }
}

- (IBAction)findMatchPressed {
    LoadingView* loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50)];
    [loadingView setMessage:@"Finding match"];
    [[self view] addSubview:loadingView];
    
    RACSignal* signal = [[[ServiceLayer instance] matchService] findMatchForUser:[[[ServiceLayer instance] authorizationService] accessToken]];
    [signal subscribeNext:^(id x) {
        // Update player
        Match* m = (Match*)x;
        assert(m);
        
        RLMRealm* realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [[[Player instance] matches] addObject:m];
        [realm commitWriteTransaction];
        
        [loadingView removeFromSuperview];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [loadingView removeFromSuperview];
        [self presentAlertControllerWithTitle:@"Match not found" andMessage:[error localizedDescription]];
    }];
}

- (IBAction)showStatistics {
    if ([self checkPremium])
        [self performSegueWithIdentifier:@"statistics" sender:self];
}

- (IBAction)logout {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"username"];
    [defaults removeObjectForKey:@"password"];
    
    //! TODO: Handle unsinchronized UserAnswer persistance
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

- (IBAction)settings:(id)sender {
    [self performSegueWithIdentifier:@"settings" sender:self];
}

- (BOOL)checkPremium {
    if (![[Player instance] premium]) {
        [self presentAlertControllerWithTitle:@"Sorry" andMessage:@"Premium account only"];
        return NO;
    }
    else
        return YES;
}

@end
