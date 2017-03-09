//
//  ChangeAvatarViewController.m
//  DotaAsker
//
//  Created by Artem on 20/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "ChangeAvatarViewController.h"
#import "Player.h"
#import "ServiceLayer.h"

@interface ChangeAvatarViewController ()

@end

@implementation ChangeAvatarViewController

@synthesize avatarNamesArray = _avatarNamesArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // [1]
    [self.collectionView setAllowsSelection:YES];
    [self.collectionView setAllowsMultipleSelection:NO];
    
    // [2]
    _avatarNamesArray = [[NSMutableArray alloc] init];
    [_avatarNamesArray addObject:@"avatar_axe.png"];
    [_avatarNamesArray addObject:@"avatar_brood.png"];
    [_avatarNamesArray addObject:@"avatar_tinker.png"];
    [_avatarNamesArray addObject:@"avatar_bristle.png"];
    [_avatarNamesArray addObject:@"avatar_bounty.png"];
    [_avatarNamesArray addObject:@"avatar_nature_prophet.png"];
    
    // [3]
    [self.collectionView reloadData];
    // Do any additional setup after loading the view.
    
    // [4]
    NSUInteger row = [_avatarNamesArray indexOfObject:[[Player instance] avatarImageName]];
    NSLog(@"Found avatar in array. Index: %lu", row);
    NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:0];
    [self.collectionView selectItemAtIndexPath:path animated:YES scrollPosition:UICollectionViewScrollPositionTop];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:path];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_avatarNamesArray count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"avatar" forIndexPath:indexPath];
    UIImageView* avatarImageView = [cell viewWithTag:100];
    UIImage* image = [UIImage imageNamed:[_avatarNamesArray objectAtIndex:[indexPath row]]];
    [avatarImageView setImage: image];
    return cell;
}

- (IBAction)backButtonPressed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // [1]
    UIImage* selectedImage = [UIImage imageNamed:[_avatarNamesArray objectAtIndex: [indexPath row]]];
    [self.selectedImageView setImage: selectedImage];
    
    // [2]
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [[Player instance] setAvatarImageName:[_avatarNamesArray objectAtIndex: [indexPath row]]];
    [realm commitWriteTransaction];
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[[ServiceLayer instance] userService] update:[Player instance]];
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
