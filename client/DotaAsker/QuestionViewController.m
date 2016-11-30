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

#define QUESTION_TIMEOUT_INTERVAL 30

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
@synthesize questionTimer = _questionTimer;
@synthesize timeTimer = _timeTimer;

- (void)viewDidLoad {
    [super viewDidLoad];
    _questionViewModel = [[QuestionViewModel alloc] init];
    _userAnswers = [[NSMutableArray alloc] init];
    _userAnswersCreatedIDs = [[NSMutableArray alloc] init];
    
    assert(_round);
    assert([[_round questions] count] == 9);
    assert(_selectedTheme);
    //! TODO: Если пустые ответы вдруг не дошли?
    // Тогда что?
    // Показывать следующий вопрос только по завершении отсыла.
    // А при ошибке как действовать? Ручной ребут?
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
    // Invalidate timer
    [_questionTimer invalidate];
    _questionTimer = nil;
    [_timeTimer invalidate];
    _timeTimer = nil;
    
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
    userAnswer.secForAnswer = QUESTION_TIMEOUT_INTERVAL - [[_timeElapsedLabel text] integerValue];
    userAnswer.ID = [[_userAnswersCreatedIDs objectAtIndex:_currentQuestionIndex] unsignedLongLongValue];
    [[_round userAnswers] addObject:userAnswer];
    
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

- (void)timeElapsed {
    NSLog(@"Timer elapsed");
    [_timeTimer invalidate];
    _timeTimer = nil;
    
    Round* relatedRound = _round;
    Answer* relatedAnswer = [Answer emptyAnswer];
    User* relatedUser = [_round nextMoveUser];
    UserAnswer *userAnswer = [[UserAnswer alloc] init];
    userAnswer.relatedRound = relatedRound;
    userAnswer.relatedAnswer = relatedAnswer;
    userAnswer.relatedUser = relatedUser;
    userAnswer.secForAnswer = QUESTION_TIMEOUT_INTERVAL;
    userAnswer.ID = [[_userAnswersCreatedIDs objectAtIndex:_currentQuestionIndex] unsignedLongLongValue];
    
    [[_round userAnswers] addObject:userAnswer];
    RACReplaySubject* subject = [[[ServiceLayer instance] userAnswerService] create:userAnswer];
    [subject subscribeNext:^(id x) {
        NSLog(@"Next");
    } error:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    } completed:^{
        NSLog(@"Completed");
    }];
    
    relatedUser.totalIncorrectAnswers++;
    _currentQuestionIndex++;
    [self showNextQuestion];
}

- (void)showNextQuestion {
    if (_currentQuestionIndex < 3) {
        // start timer
        dispatch_async(dispatch_get_main_queue(), ^{
            _questionTimer = [NSTimer scheduledTimerWithTimeInterval:QUESTION_TIMEOUT_INTERVAL
                                                       target:self
                                                     selector:@selector(timeElapsed)
                                                     userInfo:nil
                                                      repeats:NO];
            self.secondsRemain = QUESTION_TIMEOUT_INTERVAL;
            // update label with timer
            _timeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSecondsRemain) userInfo:nil repeats:YES];
        });
        
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
                //! TODO: Что делать, если не получается завершить его в данный момент?
                // Может быть сервер сам должен определять, когда следует завершить матч?
                
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
    LoadingView* loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50)];
    [loadingView setMessage:@"Surrending"];
    [[self view] addSubview:loadingView];
    
    NSMutableArray* subjectsArray = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 3; i++) {
        Round* relatedRound = _round;
        Answer* relatedAnswer;
        User* relatedUser = [Player instance];
        
        UserAnswer *userAnswer = [[UserAnswer alloc] init];
        userAnswer.relatedRound = relatedRound;
        userAnswer.relatedAnswer = relatedAnswer;
        userAnswer.relatedUser = relatedUser;
        userAnswer.secForAnswer = 30;
        RACReplaySubject* subject = [[[ServiceLayer instance] userAnswerService] create:userAnswer];
        [subjectsArray addObject:subject];
    }
    
    RACSignal *signal = [RACSignal concat:[subjectsArray.rac_sequence map:^(id sig) {
        return sig;
    }]];
    [signal subscribeNext:^(UserAnswer* newUa) {
        [_userAnswersCreatedIDs addObject:[NSNumber numberWithUnsignedLongLong:[newUa ID]]];
    } error:^(NSError *error) {
        [[self navigationController] popViewControllerAnimated:YES];
        [loadingView removeFromSuperview];
        [self presentAlertControllerWithTitle:@"Sorry, match not started" andMessage:@"Check the connection and try again :("];
    } completed:^{
        [loadingView removeFromSuperview];
        //Setting next_move_user on server to opponent
        User* opponent = [_questionViewModel opponentForRound:_round];
        // Too lazy to implement copyWithZone for each Entity
        [_round setNextMoveUser:opponent];
        [[[ServiceLayer instance] roundService] update:_round];
        [_round setNextMoveUser:[Player instance]];
    }];
}

- (void)updateSecondsRemain {
    self.secondsRemain -= 0.1;
    NSString* secondsRemain = [NSString stringWithFormat:@"%2.1f", self.secondsRemain];
    [_timeElapsedLabel setText:secondsRemain];
}

@end
