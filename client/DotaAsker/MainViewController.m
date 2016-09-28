//
//  MainViewController.m
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "MainViewController.h"
#import "MatchInfoViewController.h"
#import "MainViewModel.h"

#define SECTION_TOOLBAR 0
#define SECTION_PLAYER_INFO 1
#define SECTION_FIND_BUTTON 2
#define SECTION_CURRENT_MATCHES 3
#define SECTION_RECENT_MATCHES 4
#define SECTIONS_COUNT 5

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize viewModel = _viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    _viewModel = [[MainViewModel alloc] init];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //add refresher controll
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor whiteColor]];
    [self.refreshControl addTarget:self action:@selector(refreshControllDragged) forControlEvents:UIControlEventValueChanged];
}

- (void)refreshControllDragged {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SECTION_TOOLBAR) {
        return 1;
    }
    else if(section == SECTION_PLAYER_INFO) {
        return 1;
    }
    else if(section == SECTION_FIND_BUTTON) {
        return 1;
    }
    //current matches
    else if (section == SECTION_CURRENT_MATCHES) {
        return [_viewModel currentMatchesCount];
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
    
    static NSString *ToolbarCellIdentifier = @"toolbar_cell";
    static NSString *PlayerInfoCellIdentifier = @"player_info_cell";
    static NSString *FindMatchCellIdentifier = @"find_match_cell";
    static NSString *MatchCellIdentifier = @"match_cell";
    
    
    if ([indexPath section] == SECTION_TOOLBAR) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:ToolbarCellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.0f];
    }
    else if ([indexPath section] == SECTION_PLAYER_INFO) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:PlayerInfoCellIdentifier];
        UIImageView *playerImageView = (UIImageView*)[cell viewWithTag:200];
        [playerImageView setImage: [UIImage imageNamed:[_viewModel playerImagePath]]];
        UILabel* playerNameLabel = (UILabel*)[cell viewWithTag:201];
        [playerNameLabel setText: [_viewModel playerName]];
        [playerNameLabel setAdjustsFontSizeToFitWidth:YES];
        UILabel *mmrLabel = (UILabel*)[cell viewWithTag:202];
        [mmrLabel setText:[NSString stringWithFormat:@"MMR: %ld", (long)[_viewModel playerMMR]]];
        UILabel *KDALabel = (UILabel*)[cell viewWithTag:203];
        [KDALabel setText:[NSString stringWithFormat:@"KDA: %.2f", (float)[_viewModel playerKDA]]];
        UILabel *GPMLabel = (UILabel*)[cell viewWithTag:204];
        [GPMLabel setText:[NSString stringWithFormat:@"GPM: %.2f", (float)[_viewModel playerGPM]]];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.0f];
    }
    else if ([indexPath section] == SECTION_FIND_BUTTON) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:FindMatchCellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.0f];

    }
    else if (([indexPath section] == SECTION_CURRENT_MATCHES) || ([indexPath section] == SECTION_RECENT_MATCHES)) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:MatchCellIdentifier];
    }
    
    //filling up with user's data
    if(cell) {
        if([indexPath section] == SECTION_CURRENT_MATCHES) {
            //opponent avatar
            UIImageView *avatarView = (UIImageView*)[cell viewWithTag:100];
            UILabel *matchStateLabel = (UILabel*)[cell viewWithTag:101];
            [matchStateLabel setText:[_viewModel matchStateTextForCurrentMatch:[indexPath row]]];
            UIImage *avatar = [UIImage imageNamed:[_viewModel opponentImagePathForCurrentMatch:[indexPath row]]];
            [avatarView setImage:avatar];
            //opponent name
            UILabel *nameLabel = (UILabel*)[cell viewWithTag:103];
            [nameLabel setText:[_viewModel opponentNameForCurrentMatch:[indexPath row]]];
            [nameLabel setAdjustsFontSizeToFitWidth:YES];
        }
        else if([indexPath section] == SECTION_RECENT_MATCHES) {
            //opponent avatar
            UIImageView *avatarView = (UIImageView*)[cell viewWithTag:100];
            UILabel *matchStateLabel = (UILabel*)[cell viewWithTag:101];
            [matchStateLabel setText:[_viewModel matchStateTextForRecentMatch:[indexPath row]]];
            
            UIImage *avatar = [UIImage imageNamed:[_viewModel opponentImagePathForRecentMatch:[indexPath row]]];
            [avatarView setImage:avatar];
            //opponent name
            UILabel *nameLabel = (UILabel*)[cell viewWithTag:103];
            [nameLabel setText:[_viewModel opponentNameForRecentMatch:[indexPath row]]];
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
    else {
        return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == SECTION_TOOLBAR) {
        return 0.0f;
    }
    else if (section == SECTION_PLAYER_INFO) {
        return 0.0f;
    }
    else if (section == SECTION_FIND_BUTTON) {
        return 0.0f;
    }
    else if ((section == SECTION_CURRENT_MATCHES) || (section == SECTION_RECENT_MATCHES)) {
        return UITableViewAutomaticDimension;
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ((section == SECTION_PLAYER_INFO)||(section == SECTION_FIND_BUTTON)||(section == SECTION_TOOLBAR)) {
        UIView *headerView = [[UIView alloc] init];
        headerView.backgroundColor = [UIColor clearColor];
        return headerView;
    }
    else {
        UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
        
        // 2. Set a custom background color and a border
        headerView.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
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
        headerLabel.textAlignment = NSTextAlignmentLeft;
        
        // 4. Add the label to the header view
        [headerView addSubview:headerLabel];
        
        // 5. Finally return
        return headerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        case SECTION_TOOLBAR:
            return 40;

        default:
            return 80;
    }
}

- (void)setTableBackgroundImage:(UIImage *)backgroundImage {
    UIGraphicsBeginImageContext(self.tableView.frame.size);
    [backgroundImage drawInRect:self.tableView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showMatch"]) {
        MatchInfoViewController *destVC = (MatchInfoViewController*)[segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if ([indexPath section] == SECTION_CURRENT_MATCHES) {
            destVC.match = [_viewModel currentMatchAtRow:[indexPath row]];
        }
        else if ([indexPath section] == SECTION_RECENT_MATCHES) {
            destVC.match = [_viewModel recentMatchAtRow:[indexPath row]];
        }
    }
}

- (IBAction)findMatchPressed {
    [[self tableView] reloadData];
}

- (IBAction)logout {
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

//- (void)

@end
