//
//  AvatarCollectionViewCell.m
//  DotaAsker
//
//  Created by Artem on 05/04/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import "AvatarCollectionViewCell.h"

@implementation AvatarCollectionViewCell

@synthesize imageView = _imageView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:frame];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        _imageView.layer.borderWidth = 3;
        _imageView.layer.borderColor = [UIColor blackColor].CGColor;
    }
    else {
        _imageView.layer.borderWidth = 0;
    }
}

@end
