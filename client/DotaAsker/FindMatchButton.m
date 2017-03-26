//
//  FindMatchButton.m
//  DotaAsker
//
//  Created by Artem on 27/03/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import "FindMatchButton.h"

@implementation FindMatchButton

@synthesize backgroundLayer = _backgroundLayer;
@synthesize highlightBackgroundLayer = _highlightBackgroundLayer;
@synthesize innerGlow = _innerGlow;

@synthesize backgroundColorStart = _backgroundColorStart;
@synthesize backgroundColorEnd= _backgroundColorEnd;
@synthesize highlightBackgroundColorStart = _highlightBackgroundColorStart;
@synthesize highlightBackgroundColorEnd = _highlightBackgroundColorEnd;
@synthesize borderColor = _borderColor;

@synthesize cornerRadius = _cornerRadius;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupColors];
        [self setupLayers];
    }
    return self;
}

- (void)setupColors {
    _backgroundColorStart = [UIColor colorWithRed:0.976 green:0.658 blue:0.145 alpha:1.0];
    _backgroundColorEnd = [UIColor colorWithRed:0.960 green:0.498 blue:0.090 alpha:1.0];
    _highlightBackgroundColorStart = _backgroundColorEnd;
    _highlightBackgroundColorEnd = _backgroundColorStart;
    _cornerRadius = 4;
}

- (void)setupLayers {
    CALayer* layer = self.layer;
    layer.cornerRadius = _cornerRadius;
    layer.borderWidth = 1;
    layer.borderColor = [UIColor colorWithRed:0.22 green:0.28 blue:0.31 alpha:1.0].CGColor;
    [self setupBackgroundLayer];
    [self setupHighlightBackgroundLayer];
    [self setupGlowLayer];
    _highlightBackgroundLayer.hidden = YES;
}

- (void)setupBackgroundLayer {
    if (!_backgroundLayer) {
        _backgroundLayer = [CAGradientLayer layer];
        
        _backgroundLayer.cornerRadius = _cornerRadius;
        [_backgroundLayer setColors:(@[
                                       (id)_backgroundColorStart.CGColor,
                                       (id)_backgroundColorEnd.CGColor
                                       ])];
        
        [_backgroundLayer setLocations:(@[@0.0f, @1.0f])];
        [self.layer insertSublayer:_backgroundLayer atIndex:0];
    }
}

- (void)setupHighlightBackgroundLayer {
    if (!_highlightBackgroundLayer) {
        _highlightBackgroundLayer = [CAGradientLayer layer];
        
        _highlightBackgroundLayer.cornerRadius = _cornerRadius;
        [_highlightBackgroundLayer setColors:(@[
                                                (id)_highlightBackgroundColorStart.CGColor,
                                                (id)_highlightBackgroundColorEnd.CGColor
                                                ])];
        
        [_highlightBackgroundLayer setLocations:(@[@0.0f, @1.0f])];
        [self.layer insertSublayer:_highlightBackgroundLayer atIndex:1];
    }
}

- (void)setupGlowLayer {
    if (!_innerGlow) {
        _innerGlow = [CALayer layer];
        
        _innerGlow.cornerRadius = _cornerRadius;
        _innerGlow.borderWidth = 1;
        _innerGlow.borderColor = _borderColor.CGColor;
        _innerGlow.opacity = 0.5;
        
        [self.layer insertSublayer:_innerGlow atIndex:2];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // Set inner glow frame (1pt inset)
    _innerGlow.frame = CGRectInset(self.bounds, 1, 1);
    
    // Set gradient frame (fill the whole button))
    _backgroundLayer.frame = self.bounds;
    
    // Set inverted gradient frame
    _highlightBackgroundLayer.frame = self.bounds;
}

- (void)setHighlighted:(BOOL)highlighted
{
    // Hide/show inverted gradient
    _highlightBackgroundLayer.hidden = !highlighted;
    
    [super setHighlighted:highlighted];
}

@end
