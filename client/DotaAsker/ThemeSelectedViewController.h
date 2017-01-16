//
//  ThemeSelectedViewController.h
//  DotaAsker
//
//  Created by Artem on 17/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"
@class Round;
@class Theme;

@interface ThemeSelectedViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *themeImageView;
@property (strong, nonatomic) Theme* selectedTheme;
@property (strong, nonatomic) Round* round;
@property (assign, nonatomic) long long roundID;
@property (assign, nonatomic) long long selectedThemeID;
- (void)showQuestions;

@end
