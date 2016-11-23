//
//  ChangeAvatarViewController.m
//  DotaAsker
//
//  Created by Artem on 20/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "ChangeAvatarViewController.h"

@interface ChangeAvatarViewController ()

@end

@implementation ChangeAvatarViewController

@synthesize avatarArray = _avatarArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    _avatarArray = [[NSMutableArray alloc] init];
    [_avatarArray addObject:[UIImage imageNamed:@"avatar_axe.png"]];
    [_avatarArray addObject:[UIImage imageNamed:@"avatar_tiny.png"]];
    [_avatarArray addObject:[UIImage imageNamed:@"avatar_brood.png"]];
    [_avatarArray addObject:[UIImage imageNamed:@"avatar_tinker.png"]];
    [_avatarArray addObject:[UIImage imageNamed:@"avatar_bristle.png"]];
    [_avatarArray addObject:[UIImage imageNamed:@"avatar_bounty.png"]];
    [_avatarArray addObject:[UIImage imageNamed:@"avatar_nature_prophet.png"]];
    [self.collectionView reloadData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_avatarArray count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"avatar" forIndexPath:indexPath];
    UIImageView* avatarImageView = [cell viewWithTag:100];
    [avatarImageView setImage:[_avatarArray objectAtIndex:[indexPath row]]];
    return cell;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
}

- (IBAction)backButtonPressed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
