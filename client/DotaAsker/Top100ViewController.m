//
//  StatisticsViewController.m
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

// Local
#import "Top100ViewController.h"
#import "ServiceLayer.h"

// Libraries
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>


@interface Top100ViewController ()

@end

@implementation Top100ViewController

@synthesize results = _results;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Sort results by keys
    self.sortedKeys = [[_results allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.`
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (IBAction)backButtonPushed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_results count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *matchInfoCellIdentifier = @"result_cell";
    
    UITableViewCell* cell;
    if ([indexPath section] == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:matchInfoCellIdentifier];
        
        NSInteger key = [[_sortedKeys objectAtIndex:[indexPath row]] integerValue];
        User* u = [_results objectForKey:[NSString stringWithFormat:@"%ld", key]];
        
        // [1] place
        NSString* place = [NSString stringWithFormat:@"%ld", key];
        UILabel* labelPlace = [cell viewWithTag:100];
        [labelPlace setText:place];
        
        // [2] avatar
        UIImage* avatar = [UIImage imageNamed:[u avatarImageName]];
        UIImageView* avatarImageView = [cell viewWithTag:101];
        [avatarImageView setImage:avatar];
        
        // [3] user name
        NSString* userName = [u name];
        UILabel* userNameLabel = [cell viewWithTag:102];
        [userNameLabel setText:userName];
        
        // [4] MMR
        NSUInteger mmr = [u MMR];
        UILabel* mmrLabel = [cell viewWithTag:103];
        [mmrLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)mmr]];
        
        // [5] highlight if player
        if ([u isEqual:[Player instance]]) {
            [labelPlace setTextColor:[UIColor yellowColor]];
            [userNameLabel setTextColor:[UIColor yellowColor]];
            [mmrLabel setTextColor:[UIColor yellowColor]];
            UILabel* labelMMRText = [cell viewWithTag:104];
            [labelMMRText setTextColor:[UIColor yellowColor]];
        }
    }
    
    //making transparency
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

@end
