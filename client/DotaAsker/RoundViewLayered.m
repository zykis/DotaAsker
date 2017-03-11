//
//  RoundViewLayered.m
//  DotaAsker
//
//  Created by Artem on 10/03/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import "RoundViewLayered.h"
//#import "AnswerItemView.h"

@implementation RoundViewLayered

@synthesize shapeLayer = _shapeLayer;
@synthesize shapeLayerColor = _shapeLayerColor;

@synthesize headerWidth = _headerWidth;
@synthesize headerHeight = _headerHeight;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self base_init];
        [self initShape];
    }
    return self;
}

- (void)base_init {
    _leftAnswerViews = [[NSMutableArray alloc] init];
    _rightAnswerViews = [[NSMutableArray alloc] init];
    [_leftAnswerViews setObject:[self viewWithTag:101] atIndexedSubscript:0];
    [_leftAnswerViews setObject:[self viewWithTag:102] atIndexedSubscript:1];
    [_leftAnswerViews setObject:[self viewWithTag:103] atIndexedSubscript:2];
    [_rightAnswerViews setObject:[self viewWithTag:104] atIndexedSubscript:0];
    [_rightAnswerViews setObject:[self viewWithTag:105] atIndexedSubscript:1];
    [_rightAnswerViews setObject:[self viewWithTag:106] atIndexedSubscript:2];
    
    for (AnswerItemView* view in _leftAnswerViews) {
        [view setDelegate:self];
    }
    for (AnswerItemView* view in _rightAnswerViews) {
        [view setDelegate:self];
    }
}

- (void)answerItemViewWasTapped:(AnswerItemView *)answerItemView {
    NSInteger index = [_leftAnswerViews indexOfObjectIdenticalTo:answerItemView];
    if (index == NSNotFound) {
        index = [_rightAnswerViews indexOfObjectIdenticalTo:answerItemView];
        if (index == NSNotFound) {
            NSLog(@"Tapped answer not found");
            return;
        }
    }
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
