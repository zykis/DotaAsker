//
//  ChangeAvatarViewController.h
//  DotaAsker
//
//  Created by Artem on 20/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"

@interface ChangeAvatarViewController : UIViewController
<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSMutableArray* avatarNamesArray;
@property (strong, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (assign, nonatomic) NSInteger currentIndex;
- (IBAction)save:(id)sender;

@end
