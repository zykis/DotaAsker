//
//  TableViewCell.m
//  DotaAsker
//
//  Created by Artem on 10/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupBackground {
    
    //making transparency
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
    
    //setting image
    UIImage *resizableImage = [[UIImage imageNamed:@"cell2.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 38, 44, 57)];
    self.layer.contents = (id)resizableImage.CGImage;
}
@end
