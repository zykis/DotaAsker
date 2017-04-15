//
//  StatisticsViewController.h
//  DotaAsker
//
//  Created by Artem on 15/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"

@class User;
@class LineChartView;
@class PieChartView;
@interface StatisticsViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>

@property (assign, nonatomic) unsigned long long userID;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationTitle;
@property (strong, nonatomic) IBOutlet UILabel *mmr;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet LineChartView *chartView;
@property (strong, nonatomic) IBOutlet PieChartView *pieChartView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
