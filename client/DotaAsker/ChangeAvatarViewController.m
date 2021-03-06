//
//  ChangeAvatarViewController.m
//  DotaAsker
//
//  Created by Artem on 20/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

// Local
#import "ChangeAvatarViewController.h"
#import "Player.h"
#import "ServiceLayer.h"
#import "AvatarCollectionViewCell.h"
#import "ModalLoadingView.h"

// Libraries
#import <ReactiveObjC/ReactiveObjC.h>


@interface ChangeAvatarViewController ()

@end

@implementation ChangeAvatarViewController

@synthesize avatarNamesArray = _avatarNamesArray;
@synthesize currentIndex = _currentIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentIndex = [_avatarNamesArray indexOfObject:[[Player instance] avatarImageName]];
    [self loadBackgroundImage];
    [self loadBackgroundImageForView:self.collectionView];
    
    // [1]
    [self.collectionView setAllowsSelection:YES];
    [self.collectionView setAllowsMultipleSelection:NO];
    
    // [2]
    _avatarNamesArray = [[NSMutableArray alloc] init];
    [_avatarNamesArray addObject:@"avatar_default.png"];
    [_avatarNamesArray addObject:@"avatar_axe.png"];
    [_avatarNamesArray addObject:@"avatar_tinker.png"];
    [_avatarNamesArray addObject:@"avatar_bristle.png"];
    [_avatarNamesArray addObject:@"avatar_bounty.png"];
    [_avatarNamesArray addObject:@"avatar_nature_prophet.png"];
    
    // [3]
    [self.collectionView reloadData];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    NSUInteger row = [_avatarNamesArray indexOfObject:[[Player instance] avatarImageName]];
    assert(row != NSNotFound);
    NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:0];
    [self.collectionView selectItemAtIndexPath:path animated:YES scrollPosition:UICollectionViewScrollPositionTop];
    [self selectRow:row];
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
    AvatarCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"avatar" forIndexPath:indexPath];
    UIImage* image = [UIImage imageNamed:[_avatarNamesArray objectAtIndex:[indexPath row]]];
    [cell.imageView setImage:image];
    return cell;
}

- (IBAction)backButtonPressed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self selectRow:indexPath.row];
}

- (void)selectRow: (NSUInteger)row {
    UIImage* selectedImage = [UIImage imageNamed:[_avatarNamesArray objectAtIndex:row]];
    assert(selectedImage);
    [self.selectedImageView setImage: selectedImage];
    _currentIndex = row;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (IBAction)save:(id)sender {
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [[Player instance] setAvatarImageName:[_avatarNamesArray objectAtIndex:_currentIndex]];
    [realm commitWriteTransaction];
    
    ModalLoadingView* loadingView = [[ModalLoadingView alloc] initWithMessage:NSLocalizedString(@"Changing avatar", 0)];
    [[[UIApplication sharedApplication] keyWindow] addSubview:loadingView];
    
    RACReplaySubject* subject = [[[ServiceLayer instance] userService] update:[Player instance]];
    [subject subscribeError:^(NSError *error) {
        [self presentAlertControllerWithMessage:NSLocalizedString(@"Check out connection", 0)];
        [loadingView removeFromSuperview];
    } completed:^{
        [loadingView removeFromSuperview];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
@end
