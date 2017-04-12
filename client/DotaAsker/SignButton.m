//
//  SignButton.m
//  DotaAsker
//
//  Created by Artem on 01/04/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import "SignButton.h"

@implementation SignButton

@synthesize backgroundLayer = _backgroundLayer;
@synthesize backgroundSelectedLayer = _backgroundSelectedLayer;
@synthesize backgroundDisabledLayer = _backgroundDisabledLayer;

@synthesize backgroundColor = _backgroundColor;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _backgroundLayer = [CALayer layer];
        _backgroundSelectedLayer = [CALayer layer];
        _backgroundDisabledLayer = [CALayer layer];
        [self setupColors];
        [self setupLayers];
    }
    return self;
}

- (void)setupColors {
    _backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.35];
    _backgroundSelectedColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
    _backgroundDisabledColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    self.titleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
}

- (void)setupLayers {
    [_backgroundLayer setBackgroundColor:_backgroundColor.CGColor];
    [_backgroundSelectedLayer setBackgroundColor:_backgroundSelectedColor.CGColor];
    [_backgroundDisabledLayer setBackgroundColor:_backgroundDisabledColor.CGColor];
    
    [self.layer insertSublayer:_backgroundLayer atIndex:0];
    [self.layer insertSublayer:_backgroundSelectedLayer atIndex:1];
    [self.layer insertSublayer:_backgroundDisabledLayer atIndex:2];
    _backgroundSelectedLayer.hidden = YES;
    _backgroundDisabledLayer.hidden = YES;
}

- (void)layoutSubviews {
    [_backgroundLayer setFrame:[self bounds]];
    [_backgroundLayer setCornerRadius:[self bounds].size.height / 2];
    [_backgroundSelectedLayer setFrame:[self bounds]];
    [_backgroundSelectedLayer setCornerRadius:[self bounds].size.height / 2];
    [_backgroundDisabledLayer setFrame:[self bounds]];
    [_backgroundDisabledLayer setCornerRadius:[self bounds].size.height / 2];
    [super layoutSubviews];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    _backgroundSelectedLayer.hidden = !highlighted;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    _backgroundDisabledLayer.hidden = enabled;
    _backgroundLayer.hidden = !enabled;
    self.titleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:enabled ? 1.0 : 0.4];
}

@end
