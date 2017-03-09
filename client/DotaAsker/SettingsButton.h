//
//  ThemeButton.h
//  DotaAsker
//
//  Created by Artem on 06/03/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsButton : UIButton

@property (strong, nonatomic) CAGradientLayer* backgroundLayer;
@property (strong, nonatomic) CAGradientLayer* highlightBackgroundLayer;
@property (strong, nonatomic) CALayer* innerGlow;
@property (strong, nonatomic) CATextLayer* textLayer;
@property (strong, nonatomic) CALayer* iconLayer;

@property (strong, nonatomic) UIColor* backgroundColorStart;
@property (strong, nonatomic) UIColor* backgroundColorEnd;
@property (strong, nonatomic) UIColor* highlightBackgroundColorStart;
@property (strong, nonatomic) UIColor* highlightBackgroundColorEnd;
@property (strong, nonatomic) UIColor* captionColor;
@property (strong, nonatomic) UIColor* borderColor;

@property (strong, nonatomic) IBInspectable UIFont* textFont;
@property (strong, nonatomic) IBInspectable NSString* text;
@property (assign, nonatomic) IBInspectable CGFloat cornerRadius;
@property (strong, nonatomic) IBInspectable UIImage* icon;

@end
