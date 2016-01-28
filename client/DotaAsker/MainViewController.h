//
//  MainViewController.h
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;

@interface MainViewController : UITableViewController

@property (strong, nonatomic) User* user;
- (IBAction)findMatchPressed;
- (IBAction)logout;
//@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
