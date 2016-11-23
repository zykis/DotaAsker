//
//  SubmitQuiestionViewController.h
//  DotaAsker
//
//  Created by Artem on 20/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"

@interface SubmitQuiestionViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *textField;
@property (strong, nonatomic) IBOutlet UITextField *answer1;
@property (strong, nonatomic) IBOutlet UITextField *answer2;
@property (strong, nonatomic) IBOutlet UITextField *answer3;
@property (strong, nonatomic) IBOutlet UITextField *answer4;
- (IBAction)submit;

@end
