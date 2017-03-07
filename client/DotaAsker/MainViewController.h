//
//  MainViewController.h
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"

@class MainViewModel;

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) MainViewModel* viewModel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)findMatchPressed;
- (IBAction)showStatistics;
- (IBAction)logout;
- (IBAction)settings:(id)sender;
- (BOOL)checkPremium;

@end
