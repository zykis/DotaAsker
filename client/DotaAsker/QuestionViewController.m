//
//  QuestionViewController.m
//  DotaAsker
//
//  Created by Artem on 19/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "QuestionViewController.h"
#import "MatchInfoViewController.h"
#import "ServiceLayer.h"

@interface QuestionViewController ()

@end

@implementation QuestionViewController

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
    [self loadBackgroundImage:[[[ServiceLayer instance] userService] wallpapersDefault]];
    if (_round) {
        if ([[_round questionsIDs] count] == 0) {
            NSLog(@"No questions in Round");
            [[self navigationController] popViewControllerAnimated:YES];
            return;
        }
        _currentQuestionIndex = 0;
        [self showNextQuestion];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)answerPushed:(id)sender {
    Question *q = [[[ServiceLayer instance] questionService] questionAtIndex:_currentQuestionIndex ofRound:_round];
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

    if (answerIndex > [[q answersIDs] count] - 1) {
        return;
    }
    
    Round* relatedRound = _round;
    Question* relatedQuestion = q;
    Answer* relatedAnswer = [[[ServiceLayer instance] answerService] answerAtIndex:answerIndex ofQuestion:q];
    User* relatedUser = [[[ServiceLayer instance] userService] playerForRound:_round];
    
    UserAnswer *userAnswer = [[UserAnswer alloc] init];
    userAnswer.relatedRoundID = relatedRound.ID;
    userAnswer.relatedQuestionID = relatedQuestion.ID;
    userAnswer.relatedAnswerID = relatedAnswer.ID;
    userAnswer.relatedUserID = relatedUser.ID;
    userAnswer = [[[ServiceLayer instance] userAnswerService] create:userAnswer];
    
    
    if ([[[[ServiceLayer instance] answerService] obtain:[userAnswer relatedAnswerID]] isCorrect]) {
        //correct
        Match* match = [[[ServiceLayer instance] matchService] matchForRound:_round];
        match.scorePlayer++;
        [[[ServiceLayer instance] matchService] update:match];
        relatedUser.totalCorrectAnswers++;
    }
    else {
        relatedUser.totalIncorrectAnswers++;
        //wrong
    }
    
    [_round.answersPlayerIDs addObject:[NSNumber numberWithUnsignedLongLong:userAnswer.ID]];
    [[[ServiceLayer instance] userService] update:relatedUser];
    [self showNextQuestion];
}

- (void)showNextQuestion {
    if (_currentQuestionIndex < [[_round questionsIDs] count]) {
        Question *currentQuestion = [[[ServiceLayer instance] questionService] questionAtIndex:_currentQuestionIndex ofRound:_round];
        [_questionImageView setImage:[[[ServiceLayer instance] questionService] imageOfQuestion:currentQuestion]];
        [_questionText setText:[currentQuestion text]];
        
        Answer *answer1;
        Answer *answer2;
        Answer *answer3;
        Answer *answer4;
        
        NSInteger count = [[currentQuestion answersIDs] count];
        if (count > 0) {
            answer1 = [[[ServiceLayer instance] answerService] answerAtIndex:0 ofQuestion:currentQuestion];
            if (count > 1) {
                answer2 = [[[ServiceLayer instance] answerService] answerAtIndex:1 ofQuestion:currentQuestion];
                if (count > 2) {
                    answer3 = [[[ServiceLayer instance] answerService] answerAtIndex:2 ofQuestion:currentQuestion];
                    if (count > 3) {
                        answer4 = [[[ServiceLayer instance] answerService] answerAtIndex:3 ofQuestion:currentQuestion];
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
        _currentQuestionIndex++;
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
        
        _round = [[[ServiceLayer instance] roundService] update:_round];
        [[self navigationController] popToViewController:destVC animated:YES];
    }
}
@end
