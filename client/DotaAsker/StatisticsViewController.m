//
//  StatisticsViewController.m
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "StatisticsViewController.h"
#import "ServiceLayer.h"
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>

@interface StatisticsViewController ()

@end

@implementation StatisticsViewController

@synthesize results = _results;

- (void)viewDidLoad {
    [super viewDidLoad];
    _results = [[NSMutableArray alloc] init];
    RACReplaySubject* subject = [[[ServiceLayer instance] userService] top100];
    [subject subscribeNext:^(id x) {
        NSDictionary* dict = x;
        [_results addObject:dict];
        NSLog(@"Top100 next");
    } error:^(NSError *error) {
        NSLog(@"Top100 error: %@", [error localizedDescription]);
    } completed:^{
        NSLog(@"Top100 complited");
        [self.tableView reloadData];
    }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (IBAction)backButtonPushed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *matchInfoCellIdentifier = @"result_cell";
    
    UITableViewCell* cell;
    if ([indexPath section] == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:matchInfoCellIdentifier];
        NSDictionary* dict = [_results objectAtIndex:[indexPath row]];
        NSString* place = [[dict allKeys] firstObject];
        User* u = [dict valueForKey:place];
        UIImage* avatar = [UIImage imageNamed:[u avatarImageName]];
        NSString* userName = [u name];
        NSUInteger mmr = [u MMR];
        NSLog(@"place: %@, name: %@, mmr: %lu", place, userName, mmr);
    }
    
    //making transparency
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
    return cell;
}

@end
