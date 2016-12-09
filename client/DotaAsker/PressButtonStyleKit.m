//
//  PressButtonStyleKit.m
//  DotaAsker
//
//  Created by Zykis on 29/11/2016.
//  Copyright © 2016 Zykis. All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//
//  This code was generated by Trial version of PaintCode, therefore cannot be used for commercial purposes.
//

#import "PressButtonStyleKit.h"


@implementation PressButtonStyleKit

#pragma mark Cache

static UIColor* _greenGradientColor = nil;
static UIColor* _blackGradientColor = nil;

static PCGradient* _gradient = nil;

static NSShadow* _shadow = nil;

#pragma mark Initialization

+ (void)initialize
{
    // Colors Initialization
    _greenGradientColor = [UIColor colorWithRed: 0.305 green: 0.498 blue: 0.305 alpha: 1];
    _blackGradientColor = [UIColor colorWithRed: 0.174 green: 0.163 blue: 0.163 alpha: 1];

    // Gradients Initialization
    CGFloat gradientLocations[] = {0, 0.53, 1};
    _gradient = [PCGradient gradientWithColors: @[PressButtonStyleKit.greenGradientColor, [PressButtonStyleKit.greenGradientColor blendedColorWithFraction: 0.5 ofColor: PressButtonStyleKit.blackGradientColor], PressButtonStyleKit.blackGradientColor] locations: gradientLocations];

    // Shadows Initialization
    _shadow = [NSShadow shadowWithColor: UIColor.blackColor offset: CGSizeMake(0, 0) blurRadius: 3];

}

#pragma mark Colors

+ (UIColor*)greenGradientColor { return _greenGradientColor; }
+ (UIColor*)blackGradientColor { return _blackGradientColor; }

#pragma mark Gradients

+ (PCGradient*)gradient { return _gradient; }

#pragma mark Shadows

+ (NSShadow*)shadow { return _shadow; }

//// In Trial version of PaintCode, the code generation is limited to 3 canvases.
#pragma mark Drawing Methods

+ (void)drawButtonWithRect: (CGRect)rect
{
    [PressButtonStyleKit drawButtonWithFrame: CGRectMake(0, 0, 375, 64) resizing: PressButtonStyleKitResizingBehaviorStretch rect: rect];
}

+ (void)drawButtonWithFrame: (CGRect)targetFrame resizing: (PressButtonStyleKitResizingBehavior)resizing rect: (CGRect)rect
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Resize to Target Frame
    CGContextSaveGState(context);
    CGRect resizedFrame = PressButtonStyleKitResizingBehaviorApply(resizing, CGRectMake(0, 0, 375, 64), targetFrame);
    CGContextTranslateCTM(context, resizedFrame.origin.x, resizedFrame.origin.y);
    CGContextScaleCTM(context, resizedFrame.size.width / 375, resizedFrame.size.height / 64);
    CGFloat resizedShadowScale = MIN(resizedFrame.size.width / 375, resizedFrame.size.height / 64);


    //// Rectangle Drawing
    CGRect rectangleRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: rectangleRect cornerRadius: 8];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    CGContextDrawLinearGradient(context, PressButtonStyleKit.gradient.CGGradient,
        CGPointMake(CGRectGetMidX(rectangleRect), CGRectGetMinY(rectangleRect)),
        CGPointMake(CGRectGetMidX(rectangleRect), CGRectGetMaxY(rectangleRect)),
        kNilOptions);
    CGContextRestoreGState(context);

    ////// Rectangle Inner Shadow
    CGContextSaveGState(context);
    CGContextClipToRect(context, rectanglePath.bounds);
    CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);

    CGContextSetAlpha(context, CGColorGetAlpha([PressButtonStyleKit.shadow.shadowColor CGColor]));
    CGContextBeginTransparencyLayer(context, NULL);
    {
        UIColor* opaqueShadow = [PressButtonStyleKit.shadow.shadowColor colorWithAlphaComponent: 1];
        CGContextSetShadowWithColor(context, CGSizeMake(PressButtonStyleKit.shadow.shadowOffset.width * resizedShadowScale, PressButtonStyleKit.shadow.shadowOffset.height * resizedShadowScale), PressButtonStyleKit.shadow.shadowBlurRadius * resizedShadowScale, [opaqueShadow CGColor]);
        CGContextSetBlendMode(context, kCGBlendModeSourceOut);
        CGContextBeginTransparencyLayer(context, NULL);

        [opaqueShadow setFill];
        [rectanglePath fill];

        CGContextEndTransparencyLayer(context);
    }
    CGContextEndTransparencyLayer(context);
    CGContextRestoreGState(context);

    [UIColor.blackColor setStroke];
    rectanglePath.lineWidth = 1;
    [rectanglePath stroke];
    
    CGContextRestoreGState(context);

}

+ (void)drawCanvas1
{
    [PressButtonStyleKit drawCanvas1WithFrame: CGRectMake(0, 0, 572, 573) resizing: PressButtonStyleKitResizingBehaviorStretch];
}

+ (void)drawCanvas1WithFrame: (CGRect)targetFrame resizing: (PressButtonStyleKitResizingBehavior)resizing
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Resize to Target Frame
    CGContextSaveGState(context);
    CGRect resizedFrame = PressButtonStyleKitResizingBehaviorApply(resizing, CGRectMake(0, 0, 572, 573), targetFrame);
    CGContextTranslateCTM(context, resizedFrame.origin.x, resizedFrame.origin.y);
    CGContextScaleCTM(context, resizedFrame.size.width / 572, resizedFrame.size.height / 573);


    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 0.997 green: 0.831 blue: 0.21 alpha: 1];

    //// unlocked-padlock.svg
    {
        //// Bezier Drawing
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint: CGPointMake(342.24, 225.94)];
        [bezierPath addLineToPoint: CGPointMake(332.89, 225.94)];
        [bezierPath addLineToPoint: CGPointMake(332.89, 150.02)];
        [bezierPath addCurveToPoint: CGPointMake(188.38, 0.03) controlPoint1: CGPointMake(332.89, 69.08) controlPoint2: CGPointMake(268.66, 1.47)];
        [bezierPath addCurveToPoint: CGPointMake(179.62, 0.03) controlPoint1: CGPointMake(186.19, -0.01) controlPoint2: CGPointMake(181.81, -0.01)];
        [bezierPath addCurveToPoint: CGPointMake(35.11, 150.02) controlPoint1: CGPointMake(99.34, 1.47) controlPoint2: CGPointMake(35.11, 69.08)];
        [bezierPath addLineToPoint: CGPointMake(35.11, 151.7)];
        [bezierPath addCurveToPoint: CGPointMake(65.92, 182.52) controlPoint1: CGPointMake(35.11, 168.72) controlPoint2: CGPointMake(48.91, 182.52)];
        [bezierPath addCurveToPoint: CGPointMake(96.74, 151.7) controlPoint1: CGPointMake(82.94, 182.52) controlPoint2: CGPointMake(96.74, 168.72)];
        [bezierPath addLineToPoint: CGPointMake(96.74, 150.02)];
        [bezierPath addCurveToPoint: CGPointMake(184, 61.94) controlPoint1: CGPointMake(96.74, 101.81) controlPoint2: CGPointMake(135.92, 61.94)];
        [bezierPath addCurveToPoint: CGPointMake(271.26, 150.02) controlPoint1: CGPointMake(232.08, 61.94) controlPoint2: CGPointMake(271.26, 101.81)];
        [bezierPath addLineToPoint: CGPointMake(271.26, 225.94)];
        [bezierPath addLineToPoint: CGPointMake(25.76, 225.94)];
        [bezierPath addCurveToPoint: CGPointMake(-0.4, 259.18) controlPoint1: CGPointMake(11.35, 225.94) controlPoint2: CGPointMake(-0.4, 240.81)];
        [bezierPath addLineToPoint: CGPointMake(-0.4, 478.65)];
        [bezierPath addCurveToPoint: CGPointMake(25.76, 512) controlPoint1: CGPointMake(-0.4, 496.99) controlPoint2: CGPointMake(11.35, 512)];
        [bezierPath addLineToPoint: CGPointMake(342.24, 512)];
        [bezierPath addCurveToPoint: CGPointMake(368.4, 478.65) controlPoint1: CGPointMake(356.65, 512) controlPoint2: CGPointMake(368.4, 496.99)];
        [bezierPath addLineToPoint: CGPointMake(368.4, 259.17)];
        [bezierPath addCurveToPoint: CGPointMake(342.24, 225.94) controlPoint1: CGPointMake(368.4, 240.81) controlPoint2: CGPointMake(356.65, 225.94)];
        [bezierPath closePath];
        [bezierPath moveToPoint: CGPointMake(213.65, 368.69)];
        [bezierPath addLineToPoint: CGPointMake(213.65, 435.01)];
        [bezierPath addCurveToPoint: CGPointMake(199.69, 449.03) controlPoint1: CGPointMake(213.65, 442.6) controlPoint2: CGPointMake(207.29, 449.03)];
        [bezierPath addLineToPoint: CGPointMake(168.31, 449.03)];
        [bezierPath addCurveToPoint: CGPointMake(154.35, 435.01) controlPoint1: CGPointMake(160.71, 449.03) controlPoint2: CGPointMake(154.35, 442.6)];
        [bezierPath addLineToPoint: CGPointMake(154.35, 368.69)];
        [bezierPath addCurveToPoint: CGPointMake(142.69, 340.3) controlPoint1: CGPointMake(146.98, 361.43) controlPoint2: CGPointMake(142.69, 351.4)];
        [bezierPath addCurveToPoint: CGPointMake(179.62, 300.37) controlPoint1: CGPointMake(142.69, 319.27) controlPoint2: CGPointMake(158.95, 301.2)];
        [bezierPath addCurveToPoint: CGPointMake(188.38, 300.37) controlPoint1: CGPointMake(181.81, 300.28) controlPoint2: CGPointMake(186.19, 300.28)];
        [bezierPath addCurveToPoint: CGPointMake(225.31, 340.3) controlPoint1: CGPointMake(209.05, 301.2) controlPoint2: CGPointMake(225.31, 319.27)];
        [bezierPath addCurveToPoint: CGPointMake(213.65, 368.69) controlPoint1: CGPointMake(225.31, 351.4) controlPoint2: CGPointMake(221.02, 361.43)];
        [bezierPath closePath];
        [fillColor setFill];
        [bezierPath fill];
    }
    
    CGContextRestoreGState(context);

}

@end



@implementation PCGradient

- (instancetype)initWithColors: (NSArray<UIColor*>*)colors locations: (const CGFloat*)locations
{
    self = [self init];
    if (self != nil)
    {
        NSMutableArray* cgColors = [NSMutableArray array];
        for (UIColor* color in colors)
            [cgColors addObject: (id)color.CGColor];

        _CGGradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)cgColors, locations);
    }
    return self;
}

+ (instancetype)gradientWithColors: (NSArray<UIColor*>*)colors locations: (const CGFloat*)locations
{
    return [[self alloc] initWithColors: colors locations: locations];
}

+ (instancetype)gradientWithStartingColor: (UIColor*)startingColor endingColor: (UIColor*)endingColor
{
    return [[self alloc] initWithColors: @[startingColor, endingColor] locations: NULL];
}

- (void)dealloc
{
    CGGradientRelease(_CGGradient);
}

@end



@implementation NSShadow (PaintCodeAdditions)

- (instancetype)initWithColor: (UIColor*)color offset: (CGSize)offset blurRadius: (CGFloat)blurRadius
{
    self = [self init];
    if (self != nil)
    {
        self.shadowColor = color;
        self.shadowOffset = offset;
        self.shadowBlurRadius = blurRadius;
    }
    return self;
}

+ (instancetype)shadowWithColor: (UIColor*)color offset: (CGSize)offset blurRadius: (CGFloat)blurRadius
{
    return [[self alloc] initWithColor: color offset: offset blurRadius: blurRadius];
}

- (void)set
{
    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), self.shadowOffset, self.shadowBlurRadius, [self.shadowColor CGColor]);
}

@end



@implementation UIColor (PaintCodeAdditions)

- (UIColor*)blendedColorWithFraction: (CGFloat)fraction ofColor: (UIColor*)color2
{
    UIColor* color1 = self;

    CGFloat r1 = 0, g1 = 0, b1 = 0, a1 = 0;
    CGFloat r2 = 0, g2 = 0, b2 = 0, a2 = 0;


    [color1 getRed: &r1 green: &g1 blue: &b1 alpha: &a1];
    [color2 getRed: &r2 green: &g2 blue: &b2 alpha: &a2];

    CGFloat r = r1 * (1 - fraction) + r2 * fraction;
    CGFloat g = g1 * (1 - fraction) + g2 * fraction;
    CGFloat b = b1 * (1 - fraction) + b2 * fraction;
    CGFloat a = a1 * (1 - fraction) + a2 * fraction;

    return [UIColor colorWithRed: r green: g blue: b alpha: a];
}

@end



CGRect PressButtonStyleKitResizingBehaviorApply(PressButtonStyleKitResizingBehavior behavior, CGRect rect, CGRect target)
{
    if (CGRectEqualToRect(rect, target) || CGRectEqualToRect(target, CGRectZero))
        return rect;

    CGSize scales = CGSizeZero;
    scales.width = ABS(target.size.width / rect.size.width);
    scales.height = ABS(target.size.height / rect.size.height);

    switch (behavior)
    {
        case PressButtonStyleKitResizingBehaviorAspectFit:
        {
            scales.width = MIN(scales.width, scales.height);
            scales.height = scales.width;
            break;
        }
        case PressButtonStyleKitResizingBehaviorAspectFill:
        {
            scales.width = MAX(scales.width, scales.height);
            scales.height = scales.width;
            break;
        }
        case PressButtonStyleKitResizingBehaviorStretch:
            break;
        case PressButtonStyleKitResizingBehaviorCenter:
        {
            scales.width = 1;
            scales.height = 1;
            break;
        }
    }

    CGRect result = CGRectStandardize(rect);
    result.size.width *= scales.width;
    result.size.height *= scales.height;
    result.origin.x = target.origin.x + (target.size.width - result.size.width) / 2;
    result.origin.y = target.origin.y + (target.size.height - result.size.height) / 2;
    return result;
}