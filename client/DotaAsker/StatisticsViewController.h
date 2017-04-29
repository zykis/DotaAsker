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
@class BarChartView;
@class PieChartView;
@interface StatisticsViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSDictionary* statistic;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationTitle;
@property (strong, nonatomic) IBOutlet UILabel *mmr;
@property (strong, nonatomic) IBOutlet UILabel *labelWon;
@property (strong, nonatomic) IBOutlet UILabel *labelLost;
@property (strong, nonatomic) IBOutlet UILabel *labelGPM;
@property (strong, nonatomic) IBOutlet UILabel *labelKDA;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet BarChartView *chartView;
@property (strong, nonatomic) IBOutlet PieChartView *pieChartView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@end
