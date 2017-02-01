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
@class Theme;
@class QuestionViewModel;

@interface QuestionViewController : UIViewController

@property (assign, nonatomic) long long roundID;
@property (assign, nonatomic) long long selectedThemeID;

@property (strong, nonatomic) QuestionViewModel* questionViewModel;
@property (strong, nonatomic) IBOutlet UIImageView *questionImageView;
@property (strong, nonatomic) IBOutlet UITextView *questionText;
@property (strong, nonatomic) IBOutlet UIButton *answer1Button;
@property (strong, nonatomic) IBOutlet UIButton *answer2Button;
@property (strong, nonatomic) IBOutlet UIButton *answer3Button;
@property (strong, nonatomic) IBOutlet UIButton *answer4Button;
@property (assign, nonatomic) NSInteger currentQuestionIndex;
@property (strong, nonatomic) NSTimer* questionTimer;
@property (strong, nonatomic) NSTimer* timeTimer;
@property (strong, nonatomic) IBOutlet UILabel *timeElapsedLabel;
@property (assign, nonatomic) double secondsRemain;


- (void)updateSecondsRemain;
- (IBAction)answerPushed:(id)sender;
- (void)timeElapsed;
- (void)showNextQuestion;
- (void)popToMatchViewController;

@end
