//
//  ThemeSelectedViewController.h
//  DotaAsker
//
//  Created by Artem on 17/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"
@class Match;

@interface ThemeSelectedViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *themeImageView;
@property (weak, nonatomic) Match* match;
- (void)showQuestions;

@end
