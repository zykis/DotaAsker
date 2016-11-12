//
//  StatisticsViewController.h
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"

@interface StatisticsViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

- (IBAction)backButtonPushed:(id)sender;

@property (strong, nonatomic) NSMutableArray* results;

@property (strong, nonatomic) IBOutlet UITableView* tableView;

@end
