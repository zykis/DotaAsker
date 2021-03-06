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
@synthesize disabledBackgroundLayer = _disabledBackgroundLayer;
@synthesize innerGlow = _innerGlow;
@synthesize textLayer = _textLayer;
@synthesize iconLayer = _iconLayer;

@synthesize backgroundColorStart = _backgroundColorStart;
@synthesize backgroundColorEnd= _backgroundColorEnd;
@synthesize highlightBackgroundColorStart = _highlightBackgroundColorStart;
@synthesize highlightBackgroundColorEnd = _highlightBackgroundColorEnd;
@synthesize disabledBackgroundColor = _disabledBackgroundColor;
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
        [self drawDisabledBackgroundLayer];
        _highlightBackgroundLayer.hidden = YES;
        _disabledBackgroundLayer.hidden = YES;
    }
    return self;
}

- (void)setColors {
    _cornerRadius = 4.5;
    _textFont = [UIFont fontWithName:@"Trajan Pro 3" size:11];
    _backgroundColorStart = [UIColor colorWithRed:0.94f green:0.82f blue:0.52f alpha:1.00f];
    _backgroundColorEnd = [UIColor colorWithRed:0.91f green:0.55f blue:0.00f alpha:1.00f];
    _highlightBackgroundColorStart = [UIColor colorWithRed:0.91f green:0.55f blue:0.00f alpha:1.00f];
    _highlightBackgroundColorEnd = [UIColor colorWithRed:0.94f green:0.82f blue:0.52f alpha:1.00f];
    _disabledBackgroundColor = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1.0];
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

- (void)drawDisabledBackgroundLayer {
    if (!_disabledBackgroundLayer) {
        _disabledBackgroundLayer = [CALayer layer];
        
        _disabledBackgroundLayer.cornerRadius = _cornerRadius;
        _disabledBackgroundLayer.backgroundColor = _disabledBackgroundColor.CGColor;
        [self.layer insertSublayer:_disabledBackgroundLayer atIndex:2];
    }
}

- (void)drawInnerGlow {
    if (!_innerGlow) {
        _innerGlow = [CALayer layer];
        _innerGlow.cornerRadius = _cornerRadius;
        _innerGlow.borderWidth = 1;
        _innerGlow.borderColor = [[UIColor whiteColor] CGColor];
        _innerGlow.opacity = 0.5;
        
        [self.layer insertSublayer:_innerGlow atIndex:3];
    }
}

- (void)drawText {
    if (!_textLayer) {
        _textLayer = [CATextLayer layer];
        _textLayer.string = NSLocalizedString(_text, 0);
        _textLayer.font = CFBridgingRetain([UIFont fontWithName:@"Trajan Pro 3" size:17.0].fontName);
        _textLayer.fontSize = 17.0;
        _textLayer.foregroundColor = [UIColor whiteColor].CGColor;
        _textLayer.alignmentMode = kCAAlignmentLeft;
        _textLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer insertSublayer:_textLayer atIndex:4];
    }
}

- (void)drawIcon {
    if (!_iconLayer) {
        _iconLayer = [CALayer layer];
        _iconLayer.contents = (id)_icon.CGImage;
        [self.layer insertSublayer:_iconLayer atIndex:5];
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
    
    // Set disabled layer frame
    _disabledBackgroundLayer.frame = self.bounds;
    
    CGRect iconRect = CGRectMake(0, 0, 48, 48);
    NSUInteger margins = 15;
    _iconLayer.frame = iconRect;
    _iconLayer.anchorPoint = CGPointMake(0, 0.5);
    _iconLayer.position = CGPointMake(CGRectGetMinX(self.bounds) + margins, CGRectGetMidY(self.bounds));
    
    float labelHeight = [_text sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Trajan Pro 3" size:17] }].height;
    
    CGSize labelSize = CGSizeMake(self.bounds.size.width - iconRect.size.width - margins * 3, labelHeight);
    CGPoint labelOrigin = CGPointMake(iconRect.size.width + margins * 2, 0);
    CGRect labelRect = CGRectMake(labelOrigin.x, labelOrigin.y, labelSize.width, labelSize.height);
    
    _textLayer.frame = labelRect;
    _textLayer.anchorPoint = CGPointMake(0, 0.5);
    _textLayer.position = CGPointMake(CGRectGetMinX(self.bounds) + iconRect.size.width + margins * 2, CGRectGetMidY(self.bounds));
    _textLayer.truncationMode = kCATruncationEnd;
    
    [super layoutSubviews];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self drawIcon];
    [self drawText];
}

- (void)updateText {
    if (_textLayer) {
        _textLayer.string = _text;
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlightBackgroundLayer.hidden = !highlighted;
    [super setHighlighted:highlighted];
}

- (void)setEnabled:(BOOL)enabled {
    _disabledBackgroundLayer.hidden = enabled;
    [super setEnabled:enabled];
}

- (UIColor *)titleColorForState:(UIControlState)state {
    float alpha = 1.0f;
    if (state == UIControlStateDisabled)
        alpha = 0.54f;
    UIColor* textColor = [[UIColor whiteColor] colorWithAlphaComponent:alpha];
    return textColor;
}

@end
