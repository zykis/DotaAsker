//
//  ThemeButton.m
//  DotaAsker
//
//  Created by Artem on 06/03/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import "SettingsButton.h"

@implementation SettingsButton

@synthesize backgroundLayer = _backgroundLayer;
@synthesize highlightBackgroundLayer = _highlightBackgroundLayer;
@synthesize innerGlow = _innerGlow;
@synthesize textLayer = _textLayer;
@synthesize iconLayer = _iconLayer;

@synthesize backgroundColorStart = _backgroundColorStart;
@synthesize backgroundColorEnd= _backgroundColorEnd;
@synthesize highlightBackgroundColorStart = _highlightBackgroundColorStart;
@synthesize highlightBackgroundColorEnd = _highlightBackgroundColorEnd;
@synthesize captionColor = _captionColor;
@synthesize borderColor = _borderColor;

@synthesize textFont = _textFont;
@synthesize text = _text;
@synthesize cornerRadius = _cornerRadius;
@synthesize icon = _icon;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setColors];
        [self drawButton];
        [self drawInnerGlow];
        [self drawBackgroundLayer];
        [self drawHighlightBackgroundLayer];
//        [self drawText];
        _highlightBackgroundLayer.hidden = YES;
    }
    return self;
}

- (void)setColors {
    _cornerRadius = 4.5;
    _textFont = [UIFont fontWithName:@"Trajan" size:11];
    _backgroundColorStart = [UIColor colorWithRed:0.94f green:0.82f blue:0.52f alpha:1.00f];
    _backgroundColorEnd = [UIColor colorWithRed:0.91f green:0.55f blue:0.00f alpha:1.00f];
    _highlightBackgroundColorStart = [UIColor colorWithRed:0.91f green:0.55f blue:0.00f alpha:1.00f];
    _highlightBackgroundColorEnd = [UIColor colorWithRed:0.94f green:0.82f blue:0.52f alpha:1.00f];
}

- (void)drawButton {
    CALayer* layer = self.layer;
    layer.cornerRadius = _cornerRadius;
    layer.borderWidth = 1;
    layer.borderColor = [UIColor colorWithRed:0.77f green:0.43f blue:0.00f alpha:1.00f].CGColor;
}

- (void)drawBackgroundLayer {
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

- (void)drawHighlightBackgroundLayer {
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

- (void)drawInnerGlow {
    if (!_innerGlow) {
        _innerGlow = [CALayer layer];
        
        _innerGlow.cornerRadius = _cornerRadius;
        _innerGlow.borderWidth = 1;
        _innerGlow.borderColor = [[UIColor whiteColor] CGColor];
        _innerGlow.opacity = 0.5;
        
        [self.layer insertSublayer:_innerGlow atIndex:2];
    }
}

- (void)drawText {
    if (!_textLayer) {
        _textLayer = [CATextLayer layer];
        _textLayer.string = _text;
        _textLayer.font = CFBridgingRetain([UIFont fontWithName:@"Trajan" size:17.0].fontName);
        _textLayer.fontSize = 17.0;
        _textLayer.foregroundColor = [UIColor whiteColor].CGColor;
        _textLayer.alignmentMode = kCAAlignmentLeft;
        _textLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer insertSublayer:_textLayer atIndex:3];
    }
}

- (void)drawIcon {
    if (!_iconLayer) {
        _iconLayer = [CALayer layer];
        _iconLayer.contents = (id)_icon.CGImage;
        [self.layer insertSublayer:_iconLayer atIndex:4];
    }
}

- (void)layoutSubviews
{
    // Set inner glow frame (1pt inset)
    _innerGlow.frame = CGRectInset(self.bounds, 1, 1);
    
    // Set gradient frame (fill the whole button))
    _backgroundLayer.frame = self.bounds;
    
    // Set inverted gradient frame
    _highlightBackgroundLayer.frame = self.bounds;
    
    CGRect labelRect = [_text boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Trajan" size:17.0] } context:nil];
    _textLayer.frame = labelRect;
    _textLayer.anchorPoint = CGPointMake(0, 0.5);
    _textLayer.position = CGPointMake(CGRectGetMinX(self.bounds) + 48 + 15 * 2, CGRectGetMidY(self.bounds));
    
    CGRect iconRect = CGRectMake(0, 0, 48, 48);
    _iconLayer.frame = iconRect;
    _iconLayer.anchorPoint = CGPointMake(0, 0.5);
    _iconLayer.position = CGPointMake(CGRectGetMinX(self.bounds) + 15, CGRectGetMidY(self.bounds));
    
    
    [super layoutSubviews];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self drawIcon];
    [self drawText];
//    [self updateText];
}

- (void)updateText {
    if (_textLayer) {
        _textLayer.string = _text;
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    // Hide/show inverted gradient
    _highlightBackgroundLayer.hidden = !highlighted;
    
    [super setHighlighted:highlighted];
}

@end
