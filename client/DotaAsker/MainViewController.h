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

@interface MainViewController : UITableViewController

@property (strong, nonatomic) MainViewModel* viewModel;
- (IBAction)findMatchPressed;
- (IBAction)logout;
- (IBAction)showStatistics;
- (BOOL)checkPremium;

@end
