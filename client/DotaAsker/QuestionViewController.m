//
//  QuestionViewController.m
//  DotaAsker
//
//  Created by Artem on 19/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "QuestionViewController.h"
#import "MatchViewController.h"
#import "ServiceLayer.h"
#import "QuestionViewModel.h"
#import "Helper.h"
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>

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
@synthesize selectedTheme = _selectedTheme;
@synthesize questionViewModel = _questionViewModel;
@synthesize userAnswers = _userAnswers;
@synthesize userAnswersCreatedIDs = _userAnswersCreatedIDs;

- (void)viewDidLoad {
    [super viewDidLoad];
    _questionViewModel = [[QuestionViewModel alloc] init];
    _userAnswers = [[NSMutableArray alloc] init];
    _userAnswersCreatedIDs = [[NSMutableArray alloc] init];
    
    assert(_round);
    assert([[_round questions] count] == 9);
    assert(_selectedTheme);
    //! TODO: create empty asnwers and sent to server
    [self sendEmptyUserAnswers];
    
    _currentQuestionIndex = 0;
    [self showNextQuestion];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_userAnswers removeAllObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)answerPushed:(id)sender {
    Question *q = [[[ServiceLayer instance] roundService] questionAtIndex:_currentQuestionIndex onTheme: _selectedTheme inRound:_round];
    NSInteger answerIndex;
    if (sender == _answer1Button)
        answerIndex = 0;
    else if (sender == _answer2Button)
        answerIndex = 1;
    else if (sender == _answer3Button)
        answerIndex = 2;
    else if(sender == _answer4Button)
        answerIndex = 3;
    
    Round* relatedRound = _round;
    Answer* relatedAnswer = [[q answers] objectAtIndex:answerIndex];
    User* relatedUser = [_round nextMoveUser];
    
    UserAnswer *userAnswer = [[UserAnswer alloc] init];
    userAnswer.relatedRound = relatedRound;
    userAnswer.relatedAnswer = relatedAnswer;
    userAnswer.relatedUser = relatedUser;
    userAnswer.ID = [[_userAnswersCreatedIDs objectAtIndex:_currentQuestionIndex] unsignedLongLongValue];
    
    [[_round userAnswers] addObject:userAnswer];
//    [_userAnswers addObject:userAnswer];
    RACReplaySubject* subject = [[[ServiceLayer instance] userAnswerService] create:userAnswer];
    [subject subscribeNext:^(id x) {
        NSLog(@"Next");
    } error:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    } completed:^{
        NSLog(@"Completed");
    }];
    
    if ([relatedAnswer isCorrect]) {
        relatedUser.totalCorrectAnswers++;
    }
    else {
        relatedUser.totalIncorrectAnswers++;
    }
    _currentQuestionIndex++;
    [self showNextQuestion];
}

- (void)showNextQuestion {
    if (_currentQuestionIndex < 3) {
        Question* q = [_questionViewModel questionForQuestionIndex:_currentQuestionIndex onTheme:_selectedTheme inRound:_round];
        assert(q);
        NSArray* answers = [q answers];
        
        CGSize size = [[Helper shared] getQuestionImageViewSize];
        RACReplaySubject* subject = [[[ServiceLayer instance] questionService] obtainImageForQuestion:q withWidth:size.width andHeight:size.height];
        [subject subscribeNext:^(id x) {
            [_questionImageView setImage:x];
        } error:^(NSError *error) {
            NSLog(@"%@", [error localizedDescription]);
        } completed:^{
        }];
        
        [_questionText setText:[q text]];
        
        [_answer1Button setHidden:YES];
        [_answer2Button setHidden:YES];
        [_answer3Button setHidden:YES];
        [_answer4Button setHidden:YES];
        
        switch ([answers count]) {
            case 4:
                [_answer4Button setTitle:[[answers objectAtIndex:3] text] forState:UIControlStateNormal];
                [_answer4Button setHidden:NO];
            case 3:
                [_answer3Button setTitle:[[answers objectAtIndex:2] text] forState:UIControlStateNormal];
                [_answer3Button setHidden:NO];
            case 2:
                [_answer2Button setTitle:[[answers objectAtIndex:1] text] forState:UIControlStateNormal];
                [_answer2Button setHidden:NO];
            case 1:
                [_answer1Button setTitle:[[answers objectAtIndex:0] text] forState:UIControlStateNormal];
                [_answer1Button setHidden:NO];
        }
    }
    
    //Игрок ответил на все вопросы
    else {
        //изменяем состояние раунда
        if ([[_round userAnswers] count] < 6) {
            // Если раунд не окончен
            // Переключаем следующего игрока
            if ([[_round nextMoveUser] isEqual:[Player instance]]) {
                User* opponent = [_questionViewModel opponentForRound:_round];
                // opponent may be nil
                [_round setNextMoveUser:opponent];
            }
            else {
                [_round setNextMoveUser:[Player instance]];
            }
        }
        else {
            if ([_questionViewModel isRoundLast:_round]) {
                // Обновляем матч
                __block Match* m = [_questionViewModel matchForRound:_round];
                // Завершаем его
                RACReplaySubject* subjectFinished = [[[ServiceLayer instance] matchService] finishMatch:m];
                [subjectFinished subscribeNext:^(id x) {
                    NSLog(@"Match finished");
                    Match *updatedMatch = x;
                    [m setState:[updatedMatch state]];
                    NSLog(@"Updated");
                } error:^(NSError *error) {
                    NSLog(@"%@", [error localizedDescription]);
                } completed:^{
                    NSLog(@"Match finished (completed)");
                    //возвращаемся к MatchInfoViewController
                    MatchViewController* destVC;
                    UINavigationController *navController = [self navigationController];
                    NSInteger i_count = [[navController viewControllers] count];
                    for (int i = 0; i < i_count; i++) {
                        if ([[[navController viewControllers] objectAtIndex:i] isMemberOfClass:[MatchViewController class]]) {
                            destVC = [[navController viewControllers] objectAtIndex:i];
                        }
                    }
                    [[self navigationController] popToViewController:destVC animated:YES];
                }];
            }
            else {
                //возвращаемся к MatchInfoViewController
                MatchViewController* destVC;
                UINavigationController *navController = [self navigationController];
                NSInteger i_count = [[navController viewControllers] count];
                for (int i = 0; i < i_count; i++) {
                    if ([[[navController viewControllers] objectAtIndex:i] isMemberOfClass:[MatchViewController class]]) {
                        destVC = [[navController viewControllers] objectAtIndex:i];
                    }
                }
                [[self navigationController] popToViewController:destVC animated:YES];
            }
        }
        
        RACReplaySubject* subject = [[[ServiceLayer instance] roundService] update:_round];
        [subject subscribeNext:^(id x) {
            Round* r = x;
            [_round setNextMoveUser:[r nextMoveUser]];
            NSLog(@"Round updated: %llu", [r ID]);
        } error:^(NSError *error) {
            NSLog(@"%@", [error localizedDescription]);
        } completed:^{
            //возвращаемся к MatchInfoViewController
            MatchViewController* destVC;
            UINavigationController *navController = [self navigationController];
            NSInteger i_count = [[navController viewControllers] count];
            for (int i = 0; i < i_count; i++) {
                if ([[[navController viewControllers] objectAtIndex:i] isMemberOfClass:[MatchViewController class]]) {
                    destVC = [[navController viewControllers] objectAtIndex:i];
                }
            }
            [[self navigationController] popToViewController:destVC animated:YES];
        }];
    }
}

- (void)sendEmptyUserAnswers {
    for (NSUInteger i = 0; i < 3; i++) {
        Round* relatedRound = _round;
        Answer* relatedAnswer;
        User* relatedUser = [Player instance];
        
        UserAnswer *userAnswer = [[UserAnswer alloc] init];
        userAnswer.relatedRound = relatedRound;
        userAnswer.relatedAnswer = relatedAnswer;
        userAnswer.relatedUser = relatedUser;
        RACReplaySubject* subject = [[[ServiceLayer instance] userAnswerService] create:userAnswer];
        [subject subscribeNext:^(id x) {
            // We could store an IDs of UserAnswers and just update them
            // later. After we've got an answer to question.
            UserAnswer* ua = x;
            [_userAnswersCreatedIDs addObject:[NSNumber numberWithUnsignedLongLong:[ua ID]]];
        } error:^(NSError *error) {
            NSLog(@"Error, creating user answers. Well, that's sucks actually, cause we could be probably tricked by users");
        } completed:^{
            NSLog(@"GJ, bro!");
        }];
        
        //Setting next_move_user on server to opponent
        User* opponent = [_questionViewModel opponentForRound:_round];
        // Too lazy to implement copyWithZone for each Entity
        [_round setNextMoveUser:opponent];
        [[[ServiceLayer instance] roundService] update:_round];
        [_round setNextMoveUser:[Player instance]];
    }
}
@end
