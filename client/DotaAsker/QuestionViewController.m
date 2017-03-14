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
#import "MatchViewModel.h"
#import "Helper.h"
#import "Answer.h"
#import "UIViewController+Utils.h"

#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>
#import <Realm/Realm.h>

#define QUESTION_TIMEOUT_INTERVAL 20

@interface QuestionViewController ()

@end

@implementation QuestionViewController

@synthesize questionImageView = _questionImageView;
@synthesize questionText = _questionText;
@synthesize answer1Button = _answer1Button;
@synthesize answer2Button = _answer2Button;
@synthesize answer3Button = _answer3Button;
@synthesize answer4Button = _answer4Button;
@synthesize progressView = _progressView;
@synthesize currentQuestionIndex = _currentQuestionIndex;
@synthesize questionViewModel = _questionViewModel;

@synthesize questionTimer = _questionTimer;
@synthesize timeTimer = _timeTimer;

- (Round*)selectedRound {
    return [Round objectForPrimaryKey: [NSNumber numberWithLongLong: self.roundID]];
}

- (Theme*)selectedTheme {
    return [Theme objectForPrimaryKey: [NSNumber numberWithLongLong:self.selectedThemeID]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    _questionViewModel = [[QuestionViewModel alloc] init];
    _currentQuestionIndex = 0;
    [_progressView setProgress:1.0];
    [self showNextQuestion];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)answerPushed:(id)sender {
    // Invalidate timers
    if (_timeTimer) {
        [_timeTimer invalidate];
        _timeTimer = nil;
    }
    if (_questionTimer) {
        [_questionTimer invalidate];
        _questionTimer = nil;
    }
    
    Question *q = [[[ServiceLayer instance] roundService] questionAtIndex:_currentQuestionIndex onTheme: [self selectedTheme] inRound:[self selectedRound]];
    NSInteger answerIndex;
    if (sender == _answer1Button)
        answerIndex = 0;
    else if (sender == _answer2Button)
        answerIndex = 1;
    else if (sender == _answer3Button)
        answerIndex = 2;
    else if(sender == _answer4Button)
        answerIndex = 3;
    
    Answer* relatedAnswer = [[q answers] objectAtIndex:answerIndex];
    UserAnswer *userAnswer = [[[self selectedRound] userAnswers] lastObject];
    assert(userAnswer);
    
    // Udpate existing userAnswer
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    userAnswer.relatedAnswerID = relatedAnswer.ID;
    userAnswer.secForAnswer = QUESTION_TIMEOUT_INTERVAL - (int)_secondsRemain;
    userAnswer.relatedUserID = [Player instance].ID;
    userAnswer.relatedRoundID = [self selectedRound].ID;
    userAnswer.relatedQuestionID = q.ID;
    [realm commitWriteTransaction];
    
    User* relatedUser = [[self selectedRound] nextMoveUser];

    [realm beginWriteTransaction];
    if ([relatedAnswer isCorrect]) {
        relatedUser.totalCorrectAnswers++;
    }
    else {
        relatedUser.totalIncorrectAnswers++;
    }
    [realm commitWriteTransaction];
    
    _currentQuestionIndex++;
    [self showNextQuestion];
}



- (void)timeElapsed {
    if (_questionTimer) {
        [_questionTimer invalidate];
        _questionTimer = nil;
    }

    UserAnswer *userAnswer = [[[self selectedRound] userAnswers] lastObject];
    assert(userAnswer);

    User* relatedUser = [[self selectedRound] nextMoveUser];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    relatedUser.totalIncorrectAnswers++;
    [realm commitWriteTransaction];
    
    _currentQuestionIndex++;
    [self showNextQuestion];
}

- (void)showNextQuestion {
    if (_currentQuestionIndex < 3) {
        Question* q = [_questionViewModel questionForQuestionIndex:_currentQuestionIndex onTheme:[self selectedTheme] inRound:[self selectedRound]];
        // create empty unsynchronized userAnswer
        
        UserAnswer* ua = [[UserAnswer alloc] init];
        // generating new primary key. will be replaced after creating on server side
        long long newID = [[[ServiceLayer instance] userAnswerService] getNextPrimaryKey];
        
        ua.ID = newID;
        ua.relatedAnswerID = [Answer emptyAnswer].ID;
        ua.relatedUserID = [Player instance].ID;
        ua.relatedRoundID = [self selectedRound].ID;
        ua.relatedQuestionID = q.ID;
        ua.secForAnswer = QUESTION_TIMEOUT_INTERVAL;
        ua.synchronized = NO;
        
        // Persist unsynchronized UserAnswer
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        // Error, while trying to add existing Nested objects (User, Question, Answer etc.)
        [[[self selectedRound] userAnswers] addObject:ua];
        [realm commitWriteTransaction];
        NSLog(@"Created UA tapped ID = %lld, questionID: %ld", ua.ID, (long)ua.relatedQuestionID);
        
        self.secondsRemain = QUESTION_TIMEOUT_INTERVAL;
        
        // Start 30 seconds timer
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            _questionTimer = [NSTimer scheduledTimerWithTimeInterval:QUESTION_TIMEOUT_INTERVAL repeats:NO block:^(NSTimer * _Nonnull timer) {
                if (_timeTimer) {
                    [_timeTimer invalidate];
                    _timeTimer = nil;
                    
                    // Elapsed timer logic
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self timeElapsed];
                    });
                }
            }];
            [[NSRunLoop currentRunLoop] addTimer:_questionTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
        
        // Start timer with 0.1 sec interval
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            _timeTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
                _secondsRemain -= 0.01;
                float progress = self.secondsRemain / (float)QUESTION_TIMEOUT_INTERVAL;
                // Update UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_progressView setProgress:progress];
                });
            }];
            [[NSRunLoop currentRunLoop] addTimer:_timeTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
        
        assert(q);
        RLMArray<Answer>* answers = [q answers];
        
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
        [self sendUserAnswersToServer];
    }
}

- (void)sendUserAnswersToServer {
    LoadingView* loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50)];
    [loadingView setMessage:@"Sending answers"];
    [[self view] addSubview:loadingView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_group_t postGroup = dispatch_group_create();
        Round* round = [Round objectForPrimaryKey:@(_roundID)];
        
        for (UserAnswer* ua in [_questionViewModel playerAnswersForRound:round]) {
            if (![ua synchronized]) {
                dispatch_group_enter(postGroup);
                RACSignal* sig = [[[ServiceLayer instance] userAnswerService] create:ua];
                [sig subscribeNext:^(id  _Nullable x) {
                    for (UserAnswer* ua in [[self selectedRound] userAnswers]) {
                        UserAnswer* serverUA = (UserAnswer*)x;
                        if ([ua isEqual:serverUA]) {
                            RLMRealm* realm = [RLMRealm defaultRealm];
                            [realm beginWriteTransaction];
                            ua.synchronized = true;
                            [realm commitWriteTransaction];
                            dispatch_group_leave(postGroup);
                        }
                    }
                } error:^(NSError * _Nullable error) {
                    dispatch_group_leave(postGroup);
                } completed:^{
                }];
            }
        }
        
        BOOL timedout = dispatch_group_wait(postGroup, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
        if (timedout) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadingView removeFromSuperview];
                [self popToMatchViewController];
            });
        }
        else {
            RACReplaySubject* subject = [[[ServiceLayer instance] userService] obtainWithAccessToken:[[[ServiceLayer instance] authorizationService] accessToken]];
            [subject subscribeNext:^(id x) {
                RLMRealm* realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                [realm addOrUpdateObject:x];
                [realm commitWriteTransaction];
            } error:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [loadingView removeFromSuperview];
                    [self popToMatchViewController];
                });
            } completed:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [loadingView removeFromSuperview];
                    [self popToMatchViewController];
                });
            }];
        }
    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect questionTextRect = [_questionText frame];
    CGRect questionTextRectOld = questionTextRect;
    CGSize contentSize = [_questionText contentSize];
    questionTextRect.size = contentSize;
    questionTextRect.origin.y = questionTextRectOld.origin.y + questionTextRectOld.size.height - questionTextRect.size.height;
    [_questionText setFrame:questionTextRect];
}

- (void)popToMatchViewController {
    //возвращаемся к MatchInfoViewController
    MatchViewController* destVC;
    UINavigationController *navController = [self navigationController];
    NSInteger i_count = [[navController viewControllers] count];
    for (int i = 0; i < i_count; i++) {
        if ([[[navController viewControllers] objectAtIndex:i] isMemberOfClass:[MatchViewController class]]) {
            destVC = [[navController viewControllers] objectAtIndex:i];
        }
    }
    Match *m = [_questionViewModel matchForRound:[self selectedRound]];
    [destVC.matchViewModel setMatchID:m.ID];
    [destVC.tableView reloadData];
    [[self navigationController] popToViewController:destVC animated:YES];

}

@end
