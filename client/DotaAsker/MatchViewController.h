//
//  MatchInfoViewController.h
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Match.h"
#import "RoundView.h"

@class MatchViewModel;

@interface MatchViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, RoundViewDelegate>

@property (assign, nonatomic) NSUInteger matchID;
@property (strong, nonatomic) MatchViewModel *matchViewModel;
@property (strong, nonatomic) IBOutlet UITableView* tableView;

#pragma mark - Navigation
- (IBAction)backButtonPushed:(id)sender;
- (IBAction)midleButtonPushed:(id)sender;

#pragma mark - Initialization
- (void)setBackgroundImage: (UIImage*)backgroundImage;
@end
