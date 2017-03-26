//
//  FindMatchButton.h
//  DotaAsker
//
//  Created by Artem on 27/03/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindMatchButton : UIButton

@property (strong, nonatomic) CAGradientLayer* backgroundLayer;
@property (strong, nonatomic) CAGradientLayer* highlightBackgroundLayer;
@property (strong, nonatomic) CALayer* innerGlow;

@property (strong, nonatomic) UIColor* backgroundColorStart;
@property (strong, nonatomic) UIColor* backgroundColorEnd;
@property (strong, nonatomic) UIColor* highlightBackgroundColorStart;
@property (strong, nonatomic) UIColor* highlightBackgroundColorEnd;
@property (strong, nonatomic) UIColor* borderColor;

@property (assign, nonatomic) float cornerRadius;

@end
