//
//  StatisticsViewController.h
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"

@interface Top100ViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

- (IBAction)backButtonPushed:(id)sender;

@property (strong, nonatomic) NSMutableDictionary* results;
@property (strong, nonatomic) NSArray* sortedKeys;

@property (strong, nonatomic) IBOutlet UITableView* tableView;

@end
