//
//  ThemeSelectionViewController.h
//  DotaAsker
//
//  Created by Artem on 14/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"

@class Round;
@class ThemeButton;

@interface ThemeSelectionViewController : UIViewController
@property (strong, nonatomic) IBOutlet ThemeButton* imagedButton1;
@property (strong, nonatomic) IBOutlet ThemeButton* imagedButton2;
@property (strong, nonatomic) IBOutlet ThemeButton* imagedButton3;
@property (assign, nonatomic) long long roundID;
- (IBAction)button1Pressed:(id)sender;
- (IBAction)button2Pressed:(id)sender;
- (IBAction)button3Pressed:(id)sender;

@end
