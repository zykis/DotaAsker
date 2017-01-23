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

@interface ThemeSelectionViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *imagedButton1;
@property (strong, nonatomic) IBOutlet UIButton *imagedButton2;
@property (strong, nonatomic) IBOutlet UIButton *imagedButton3;
@property (assign, nonatomic) NSUInteger roundID;
- (IBAction)button1Pressed:(id)sender;
- (IBAction)button2Pressed:(id)sender;
- (IBAction)button3Pressed:(id)sender;

@end
