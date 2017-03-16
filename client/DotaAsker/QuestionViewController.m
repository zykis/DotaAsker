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
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//        selector:@selector(pauseApp) 
//        name:@"UIApplicationDidEnterBackgroundNotification"
//        object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//        selector:@selector(resumeApp) 
//        name:@"UIApplicationDidBecomeActiveNotification"
//        object:nil];
}

//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//        name:@"UIApplicationDidEnterBackgroundNotification"
//        object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//        name:@"UIApplicationDidBecomeActiveNotification"
//        object:nil];
//}

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
        [self startTimersWithExpirationInterval: QUESTION_TIMEOUT_INTERVAL andProgressUpdateInterval: 0.01];
        
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
        [self sendUserAnswersToServerUsingSemaphores];
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

- (void)sendUserAnswersToServerUsingSemaphores {
    // Check out UserAnswers count
    Round* r = [Round objectForPrimaryKey:@(_roundID)];
    if ([[_questionViewModel playerAnswersForRound:r] count] < 3) {
        NSLog(@"UserAnswers count < 3. Not sending to server");
        return;
    }
    
    // Present LoadingView
    LoadingView* loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50)];
    [loadingView setMessage:@"Sending answers"];
    [[self view] addSubview:loadingView];
    
    dispatch_time_t timeoutTime = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // Create UA1
        dispatch_semaphore_t semaphoreUA1 = dispatch_semaphore_create(0);
        Round* round = [Round objectForPrimaryKey:@(_roundID)];
        UserAnswer* ua1 = [[_questionViewModel playerAnswersForRound:round] objectAtIndex:0];
        RACSignal* sig1 = [[[ServiceLayer instance] userAnswerService] create:ua1];
        __block BOOL obtained = NO;
        [sig1 subscribeNext:^(id  _Nullable x) {
                        for (UserAnswer* ua in [[self selectedRound] userAnswers]) {
                            if ([ua isEqual:x]) {
                                RLMRealm* realm = [RLMRealm defaultRealm];
                                [realm beginWriteTransaction];
                                ua.synchronized = true;
                                [realm commitWriteTransaction];
                                obtained = YES;
                                NSLog(@"UA1 obtained");
                            }
                        }
                    } error:^(NSError * _Nullable error) {
                        dispatch_semaphore_signal(semaphoreUA1);
                    } completed:^{
                        dispatch_semaphore_signal(semaphoreUA1);
                    }];
        if (dispatch_semaphore_wait(semaphoreUA1, timeoutTime)) {
            NSLog(@"Timedout during creating UA1");
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadingView removeFromSuperview];
                [self popToMatchViewController];
            });
            return;
        }
        if (!obtained) {
            NSLog(@"Failed to obtain UA1");
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadingView removeFromSuperview];
                [self popToMatchViewController];
            });
            return;
        }
        obtained = NO;
        
        // Create UA2
        dispatch_semaphore_t semaphoreUA2 = dispatch_semaphore_create(0);
        UserAnswer* ua2 = [[_questionViewModel playerAnswersForRound:round] objectAtIndex:1];
        RACSignal* sig2 = [[[ServiceLayer instance] userAnswerService] create:ua2];
        [sig2 subscribeNext:^(id  _Nullable x) {
                        for (UserAnswer* ua in [[self selectedRound] userAnswers]) {
                            if ([ua isEqual:x]) {
                                RLMRealm* realm = [RLMRealm defaultRealm];
                                [realm beginWriteTransaction];
                                ua.synchronized = true;
                                [realm commitWriteTransaction];
                                obtained = YES;
                                NSLog(@"UA2 obtained");
                            }
                        }
                    } error:^(NSError * _Nullable error) {
                        dispatch_semaphore_signal(semaphoreUA2);
                    } completed:^{
                        dispatch_semaphore_signal(semaphoreUA2);
                    }];
                    
        
        if (dispatch_semaphore_wait(semaphoreUA2, timeoutTime)) {
            NSLog(@"Timedout during creating UA2");
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadingView removeFromSuperview];
                [self popToMatchViewController];
            });
            return;
        }
        if (!obtained) {
            NSLog(@"Failed to obtain UA2");
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadingView removeFromSuperview];
                [self popToMatchViewController];
            });
            return;
        }
        obtained = NO;
        
        // Create UA3
        dispatch_semaphore_t semaphoreUA3 = dispatch_semaphore_create(0);
        UserAnswer* ua3 = [[_questionViewModel playerAnswersForRound:round] objectAtIndex:2];
        RACSignal* sig3 = [[[ServiceLayer instance] userAnswerService] create:ua3];
        [sig3 subscribeNext:^(id  _Nullable x) {
                        for (UserAnswer* ua in [[self selectedRound] userAnswers]) {
                            if ([ua isEqual:x]) {
                                RLMRealm* realm = [RLMRealm defaultRealm];
                                [realm beginWriteTransaction];
                                ua.synchronized = true;
                                [realm commitWriteTransaction];
                                obtained = YES;
                                NSLog(@"UA3 obtained");
                            }
                        }
                    } error:^(NSError * _Nullable error) {
                        dispatch_semaphore_signal(semaphoreUA3);
                    } completed:^{
                        dispatch_semaphore_signal(semaphoreUA3);
                    }];
                    
        
        if (dispatch_semaphore_wait(semaphoreUA3, timeoutTime)) {
            NSLog(@"Timedout during creating UA3");
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadingView removeFromSuperview];
                [self popToMatchViewController];
            });
            return;
        }
        if (!obtained) {
            NSLog(@"Failed to obtain UA3");
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadingView removeFromSuperview];
                [self popToMatchViewController];
            });
            return;
        }
        
        // UserAnswers has been updated.
        // Updaing Player and tableView
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

- (void)startTimersWithExpirationInterval: (double)expirationIntervalSeconds andProgressUpdateInterval: (double)progressIntervalSeconds {    
    self.secondsRemain = expirationIntervalSeconds;
        
    // Start expirationIntervalSeconds seconds timer
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        _questionTimer = [NSTimer scheduledTimerWithTimeInterval:expirationIntervalSeconds repeats:NO block:^(NSTimer * _Nonnull timer) {
            if (_timeTimer) {
                [_timeTimer invalidate];
                _timeTimer = nil;
                // Elapsed timer logic
                [self timeElapsed];
            }
        }];
        [[NSRunLoop currentRunLoop] addTimer:_questionTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    });
    
    // Start timer with progressIntervalSeconds sec interval
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        _timeTimer = [NSTimer scheduledTimerWithTimeInterval:progressIntervalSeconds repeats:YES block:^(NSTimer * _Nonnull timer) {
            _secondsRemain -= progressIntervalSeconds;
            float progress = self.secondsRemain / (double)QUESTION_TIMEOUT_INTERVAL;
            // Update UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [_progressView setProgress:progress];
            });
        }];
        [[NSRunLoop currentRunLoop] addTimer:_timeTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)pauseApp {
    // Save current timestamp
    NSDate* now = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"pauseDate"];
    
    // Invalidate progress timer
    [_timeTimer invalidate];
    _timeTimer = nil;
    
    // Invalidate main timer
    [_questionTimer invalidate];
    _questionTimer = nil;
}

- (void)resumeApp {
    // get saved timestamp
    NSDate* pauseDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"pauseDate"];
    if (pauseDate == nil)
        return;
        
    // get difference in seconds
    double intervalInSeconds = [pauseDate timeIntervalSinceNow];
    _secondsRemain = MIN(_secondsRemain - intervalInSeconds, 0);
    if (_secondsRemain == 0) {
        // Timer expired. Update UI
        [_progressView setProgress:0];
        // Elapsed timer logic
        [self timeElapsed];
    }
    else {
        // Start main timer
        [self startTimersWithExpirationInterval: _secondsRemain andProgressUpdateInterval: 0.01];
    }
    
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pauseDate"];
}

@end
