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
        [self drawShape];
    }
    return self;
}

- (void)base_init {
    _leftAnswerViews = [[NSMutableArray alloc] init];
    _rightAnswerViews = [[NSMutableArray alloc] init];
    
    [_rightAnswerViews setObject:[self viewWithTag:101] atIndexedSubscript:0];
    [_rightAnswerViews setObject:[self viewWithTag:102] atIndexedSubscript:1];
    [_rightAnswerViews setObject:[self viewWithTag:103] atIndexedSubscript:2];
    
    [_leftAnswerViews setObject:[self viewWithTag:104] atIndexedSubscript:0];
    [_leftAnswerViews setObject:[self viewWithTag:105] atIndexedSubscript:1];
    [_leftAnswerViews setObject:[self viewWithTag:106] atIndexedSubscript:2];
    
    for (AnswerItemView* view in _rightAnswerViews) {
        [view setDelegate:self];
    }
    for (AnswerItemView* view in _leftAnswerViews) {
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

- (void)drawShape {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _headerHeight = 20;
        _headerWidth = 70;
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
        
        _shapeLayer.path = figurePath.CGPath;
        _shapeLayer.anchorPoint = CGPointMake(0.5, 0.5);
        _shapeLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        _shapeLayer.fillColor = _shapeLayerColor.CGColor;
        _shapeLayer.strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor;
        [self.layer insertSublayer:_shapeLayer atIndex:0];
    }
}

- (void)layoutSubviews {
    if (_shapeLayer) {
        _shapeLayer.bounds = self.bounds;
    }
    [super layoutSubviews];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (_shapeLayer) {
        _shapeLayer.fillColor = _shapeLayerColor.CGColor;
    }
}

//- (CGPathRef)shapePath {
//    CGFloat w = self.bounds.size.width;
//    CGFloat h = self.bounds.size.height;
//    CGFloat h_w = _headerWidth;
//    CGFloat h_h = _headerHeight;
//    CGFloat r = 4.5;
//    
//    UIBezierPath* path;
//    // 1. (r, h_h)
//    [path moveToPoint:CGPointMake(r, h_h)];
//    // 2. ((w - h_w) / 2, h_h)
//    [path addLineToPoint:CGPointMake((w - h_w) / 2, h_h)];
//    // 3. (
//    
//    return path.CGPath;
//}

@end
