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

@interface MatchInfoViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, RoundViewDelegate>

@property (strong, nonatomic) Match *match;
@property (strong, nonatomic) IBOutlet UITableView* tableView;

#pragma mark - Navigation
- (IBAction)backButtonPushed:(id)sender;
- (IBAction)midleButtonPushed:(id)sender;

#pragma mark - Initialization
- (void)setBackgroundImage: (UIImage*)backgroundImage;
@end
