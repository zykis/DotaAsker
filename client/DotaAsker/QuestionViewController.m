//
//  QuestionViewController.m
//  DotaAsker
//
//  Created by Artem on 19/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "QuestionViewController.h"
#import "MatchInfoViewController.h"
#import "Round.h"
#import "Question.h"
#import "UserAnswer.h"
#import "Player.h"
#import "Answer.h"
#import "Client.h"

@interface QuestionViewController ()

@end

@implementation QuestionViewController

@synthesize match = _match;
@synthesize round = _round;
@synthesize questionImageView = _questionImageView;
@synthesize questionText = _questionText;
@synthesize answer1Button = _answer1Button;
@synthesize answer2Button = _answer2Button;
@synthesize answer3Button = _answer3Button;
@synthesize answer4Button = _answer4Button;
@synthesize currentQuestionIndex = _currentQuestionIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    if (_round) {
        if ([[_round questions] count] == 0) {
            NSLog(@"No questions in Round");
            [[self navigationController] popViewControllerAnimated:YES];
            return;
        }
        Question *firstQuestion = [[_round questions] objectAtIndex:0];
        _currentQuestionIndex = 0;
        [_questionImageView setImage:[firstQuestion image]];
        [_questionText setText:[firstQuestion text]];
        
        Answer *answer1;
        Answer *answer2;
        Answer *answer3;
        Answer *answer4;
        
        NSInteger count = [[firstQuestion answers] count];
        if (count > 0) {
            answer1 = [[firstQuestion answers] objectAtIndex:0];
            if (count > 1) {
                answer2 = [[firstQuestion answers] objectAtIndex:1];
                if (count > 2) {
                    answer3 = [[firstQuestion answers] objectAtIndex:2];
                    if (count > 3) {
                        answer4 = [[firstQuestion answers] objectAtIndex:3];
                    }
                }
            }
        }

        if (answer1) {
            [_answer1Button setTitle:[answer1 text] forState:UIControlStateNormal];
        }
        else {
            [_answer1Button setTitle:@"" forState:UIControlStateNormal];
        }
        
        if (answer2) {
            [_answer2Button setTitle:[answer2 text] forState:UIControlStateNormal];
        }
        else {
            [_answer2Button setTitle:@"" forState:UIControlStateNormal];
        }
        
        if (answer3) {
            [_answer3Button setTitle:[answer3 text] forState:UIControlStateNormal];
        }
        else {
            [_answer3Button setTitle:@"" forState:UIControlStateNormal];
        }
        
        if (answer4) {
            [_answer4Button setTitle:[answer4 text] forState:UIControlStateNormal];
        }
        else {
            [_answer4Button setTitle:@"" forState:UIControlStateNormal];
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)answerPushed:(id)sender {
    Question *q = (Question*)[[_round questions] objectAtIndex:_currentQuestionIndex];
    NSInteger answerIndex;
    if (sender == _answer1Button)
        answerIndex = 0;
    else if (sender == _answer2Button)
        answerIndex = 1;
    else if (sender == _answer3Button)
        answerIndex = 2;
    else if(sender == _answer4Button)
        answerIndex = 3;
    else {
        NSLog(@"What button was tapped?");
    }

    if (answerIndex > [[q answers] count] - 1) {
        return;
    }
    
    UserAnswer *userAnswer = [[UserAnswer alloc] initAnswerRelatedToQuestion:q
                                    answer:[[q answers] objectAtIndex:answerIndex]
                                    andRound:_round];
    [userAnswer setUserID:[[Player instance] ID]];
    
    if ([[userAnswer relatedAnswer] isCorrect]) {
        //correct
        _match.scorePlayer++;
    }
    else {
        //wrong
    }
    _round.answersPlayer = [[_round.answersPlayer arrayByAddingObject:userAnswer] mutableCopy];
    [[Client instance] sendMessagePostUserAnswer:userAnswer];
    [self showNextQuestion];
}

- (void)showNextQuestion {
    _currentQuestionIndex++;
    if (_currentQuestionIndex < [[_round questions] count]) {
        Question *currentQuestion = [[_round questions] objectAtIndex:_currentQuestionIndex];
        [_questionImageView setImage:[currentQuestion image]];
        [_questionText setText:[currentQuestion text]];
        
        Answer *answer1;
        Answer *answer2;
        Answer *answer3;
        Answer *answer4;
        
        NSInteger count = [[currentQuestion answers] count];
        if (count > 0) {
            answer1 = [[currentQuestion answers] objectAtIndex:0];
            if (count > 1) {
                answer2 = [[currentQuestion answers] objectAtIndex:1];
                if (count > 2) {
                    answer3 = [[currentQuestion answers] objectAtIndex:2];
                    if (count > 3) {
                        answer4 = [[currentQuestion answers] objectAtIndex:3];
                    }
                }
            }
        }
        
        if (answer1) {
            [_answer1Button setTitle:[answer1 text] forState:UIControlStateNormal];
        }
        else {
            [_answer1Button setTitle:@"" forState:UIControlStateNormal];
        }
        
        if (answer2) {
            [_answer2Button setTitle:[answer2 text] forState:UIControlStateNormal];
        }
        else {
            [_answer2Button setTitle:@"" forState:UIControlStateNormal];
        }
        
        if (answer3) {
            [_answer3Button setTitle:[answer3 text] forState:UIControlStateNormal];
        }
        else {
            [_answer3Button setTitle:@"" forState:UIControlStateNormal];
        }
        
        if (answer4) {
            [_answer4Button setTitle:[answer4 text] forState:UIControlStateNormal];
        }
        else {
            [_answer4Button setTitle:@"" forState:UIControlStateNormal];
        }
        
    }
    
    //на все вопросы ответили
    else {
        //изменяем состояние раунда
        switch ([_round round_state]) {
            case ROUND_PLAYER_ASWERING: {
                [_round setRound_state:ROUND_OPPONENT_REPLYING];
                break;
            }
            
            case ROUND_PLAYER_REPLYING: {
                [_round setRound_state:ROUND_FINISHED];
                break;
            }
                
            default:
                break;
        }
        //возвращаемся к MatchInfoViewController
        MatchInfoViewController* destVC;
        UINavigationController *navController = [self navigationController];
        if (navController == nil) {
            NSLog(@"Navigation Controller is missing");
            
        }
        NSInteger i_count = [[navController viewControllers] count];
        for (int i = 0; i < i_count; i++) {
            if ([[[navController viewControllers] objectAtIndex:i] isMemberOfClass:[MatchInfoViewController class]]) {
                destVC = [[navController viewControllers] objectAtIndex:i];
            }
        }
        if (!destVC) {
            NSLog(@"Main View Controller not found");
            return;
        }
        
        [[Player instance] saveToSettings];
        [[Client instance] sendMessageUpdateRound:_round];
        if ([[[_match rounds] lastObject] isEqual:_round]) {
            //last round finished. need to send update request for match to server
            [[Client instance] sendMessageUpdateMatch:_match];
            //also update users
            [[Client instance] sendMessageUpdateUser:(User*)[Player instance]];
            [[Client instance] sendMessageUpdateUser:[_match opponent]];
        }
        [[self navigationController] popToViewController:destVC animated:YES];
    }
}
@end
