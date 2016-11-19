//
//  StatisticsViewController.h
//  DotaAsker
//
//  Created by Artem on 15/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@interface StatisticsViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) User* user;
@property (assign, nonatomic) unsigned long long userID;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationTitle;
@property (strong, nonatomic) IBOutlet UILabel *mmr;
@property (strong, nonatomic) IBOutlet UILabel *kda;
@property (strong, nonatomic) IBOutlet UILabel *gpm;
@property (strong, nonatomic) IBOutlet UILabel *answerTime;
@property (strong, nonatomic) IBOutlet UILabel *averageCorrectAnswers;
@property (strong, nonatomic) IBOutlet UILabel *wins;
@property (strong, nonatomic) IBOutlet UILabel *lost;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UIView *chart;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
