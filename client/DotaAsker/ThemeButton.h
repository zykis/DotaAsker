//
//  ThemeButton.h
//  DotaAsker
//
//  Created by Artem on 06/03/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeButton : UIButton

@property (strong, nonatomic) CAGradientLayer* highlightLayer;
@property (strong, nonatomic) CAGradientLayer* highlightBackgroundLayer;
@property (strong, nonatomic) CALayer* innerGlow;

@end
