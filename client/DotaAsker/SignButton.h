//
//  SignButton.h
//  DotaAsker
//
//  Created by Artem on 01/04/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignButton : UIButton

@property (strong, nonatomic) CALayer* backgroundLayer;
@property (strong, nonatomic) CALayer* backgroundSelectedLayer;
@property (strong, nonatomic) CALayer* backgroundDisabledLayer;

@property (strong, nonatomic) UIColor* backgroundColor;
@property (strong, nonatomic) UIColor* backgroundSelectedColor;
@property (strong, nonatomic) UIColor* backgroundDisabledColor;

@end
