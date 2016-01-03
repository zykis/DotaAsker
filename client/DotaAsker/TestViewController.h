//
//  TestViewController.h
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ServiceLayer;

@interface TestViewController : UIViewController
@property (strong, nonatomic) ServiceLayer* serviceLayer;
- (IBAction)onButton;
@property (strong, nonatomic) IBOutlet UILabel *label;

@end
