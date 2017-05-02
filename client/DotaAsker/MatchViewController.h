//
//  MatchInfoViewController.h
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Match.h"
#import "RoundViewLayered.h"

@class MatchViewModel;
@class SettingsButton;

@interface MatchViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, RoundViewDelegate>

@property (assign, nonatomic) NSUInteger buttonState;
@property (assign, nonatomic) long long matchID;
@property (strong, nonatomic) MatchViewModel *matchViewModel;
@property (strong, nonatomic) IBOutlet UITableView* tableView;

#pragma mark - Navigation
- (IBAction)backButtonPushed:(id)sender;
- (IBAction)midleButtonPushed:(id)sender;
- (IBAction)sendFriendRequest:(id)sender;
- (IBAction)surrend:(id)sender;

@end
