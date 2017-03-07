//
//  Palette.h
//  DotaAsker
//
//  Created by Artem on 07/03/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Palette : NSObject

@property (strong, nonatomic) UIColor* backgroundColor;
@property (strong, nonatomic) UIColor* navigationPanelColor;
@property (strong, nonatomic) UIColor* statusBarColor;

@property (strong, nonatomic) UIColor* themesButtonColor;
@property (strong, nonatomic) UIColor* findMatchButtonColor;
@property (strong, nonatomic) UIColor* roundViewColor;

@property (strong, nonatomic) UIImage* pattern;

+ (Palette*)shared;


@end
