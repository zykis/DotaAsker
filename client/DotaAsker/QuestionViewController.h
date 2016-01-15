//
//  QuestionViewController.h
//  DotaAsker
//
//  Created by Artem on 19/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"
@class Round;
@class Match;

@interface QuestionViewController : UIViewController

@property (strong, nonatomic) Round *round;
@property (strong, nonatomic) IBOutlet UIImageView *questionImageView;
@property (strong, nonatomic) IBOutlet UITextView *questionText;
@property (strong, nonatomic) IBOutlet UIButton *answer1Button;
@property (strong, nonatomic) IBOutlet UIButton *answer2Button;
@property (strong, nonatomic) IBOutlet UIButton *answer3Button;
@property (strong, nonatomic) IBOutlet UIButton *answer4Button;
@property (assign, nonatomic) NSInteger currentQuestionIndex;
- (IBAction)answerPushed:(id)sender;
- (void)showNextQuestion;

@end
