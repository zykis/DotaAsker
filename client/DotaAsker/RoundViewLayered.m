//
//  RoundViewLayered.m
//  DotaAsker
//
//  Created by Artem on 10/03/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import "RoundViewLayered.h"

@implementation RoundViewLayered

@synthesize shapeLayer = _shapeLayer;
@synthesize shapeLayerColor = _shapeLayerColor;

@synthesize headerWidth = _headerWidth;
@synthesize headerHeight = _headerHeight;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initShape];
    }
    return self;
}

- (void)answerItemViewWasTapped:(AnswerItemView *)answerItemView {
    NSInteger index = [answerItemView tag] - 101;
    [self.delegate roundViewAnswerWasTapped:self atIndex:index];
}

- (void)initShape {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = _shapeLayerColor.CGColor;
        [self.layer insertSublayer:_shapeLayer atIndex:0];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_shapeLayer) {
        _shapeLayer.path = [self shapePath];
        _shapeLayer.bounds = self.bounds;
        _shapeLayer.anchorPoint = CGPointMake(0.5, 0.5);
        _shapeLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (_shapeLayer) {
        _shapeLayer.fillColor = _shapeLayerColor.CGColor;
    }
    
}

- (CGPathRef)shapePath {
    CGRect mainRect = self.bounds;
    mainRect.size.height -= 5;
    
    CGRect headerRect;
    headerRect.size.width = _headerWidth;
    headerRect.size.height = _headerHeight;
    headerRect.origin.x = (mainRect.size.width - _headerWidth) / 2;
    headerRect.origin.y = 0;
    
    CGRect bottomRect = CGRectMake(0, _headerHeight / 2, mainRect.size.width, mainRect.size.height - _headerHeight / 2);
    
    UIBezierPath* figurePath = [UIBezierPath bezierPathWithRoundedRect:bottomRect cornerRadius:4.5];
    [figurePath appendPath:[UIBezierPath bezierPathWithRoundedRect:headerRect cornerRadius:4.5]];
    
    return figurePath.CGPath;
}

@end
