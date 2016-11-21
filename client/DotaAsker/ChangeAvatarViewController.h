//
//  ChangeAvatarViewController.h
//  DotaAsker
//
//  Created by Artem on 20/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeAvatarViewController : UIViewController
<UICollectionViewDataSource>

@property (strong, nonatomic) NSMutableArray* avatarArray;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end
