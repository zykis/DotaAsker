//
//  AvatarCollectionViewCell.m
//  DotaAsker
//
//  Created by Artem on 05/04/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import "AvatarCollectionViewCell.h"
#import "Palette.h"

@implementation AvatarCollectionViewCell

@synthesize imageView = _imageView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        [self.contentView addSubview: _imageView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _imageView = [[UIImageView alloc] initWithCoder:aDecoder];
        [self.contentView addSubview: _imageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        _imageView.layer.borderWidth = 1.8f;
        _imageView.layer.borderColor = [[Palette shared] themesButtonColor].CGColor;
        _imageView.layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor;
        _imageView.layer.cornerRadius = 4.5f;
    }
    else {
        _imageView.layer.borderWidth = 1;
        _imageView.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.8].CGColor;
        _imageView.layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor;
        _imageView.layer.cornerRadius = 4.5f;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.contentView.frame;
}

@end
