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
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>
#import <Realm/Realm.h>

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
@synthesize questionTimer = _questionTimer;
@synthesize timeTimer = _timeTimer;

dispatch_source_t CreateDispatchTimer(uint64_t interval, uint64_t leeway, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _questionViewModel = [[QuestionViewModel alloc] init];
    
    assert(_round);
    assert([[_round questions] count] == 9);
    assert(_selectedTheme);
    
    _currentQuestionIndex = 0;
    [self showNextQuestion];
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
    
    Answer* relatedAnswer = [[q answers] objectAtIndex:answerIndex];
    UserAnswer *userAnswer = [[_round userAnswers] lastObject];
    
    // Udpate existing userAnswer
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    userAnswer.relatedAnswer = relatedAnswer;
    userAnswer.secForAnswer = QUESTION_TIMEOUT_INTERVAL - [[_timeElapsedLabel text] integerValue];
    [realm commitWriteTransaction];
    
    RACReplaySubject* subject = [[[ServiceLayer instance] userAnswerService] create:userAnswer];
    [subject subscribeNext:^(id x) {
        // Mark userAnswer as synchronized
        for (int i = 0; i < [[_round userAnswers] count]; i++) {
            UserAnswer* ua = [[_round userAnswers] objectAtIndex:i];
            if ([ua isEqual:x]) {
                ua = x;
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                ua.synchronized = true;
                [realm commitWriteTransaction];
            }
        }
    } error:^(NSError *error) {
        NSLog(@"Answer synchronize failed: %@", [error localizedDescription]);
    } completed:^{
        NSLog(@"Answer synchronized");
    }];
    
    User* relatedUser = [_round nextMoveUser];

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

    UserAnswer *userAnswer = [[_round userAnswers] lastObject];

    RACReplaySubject* subject = [[[ServiceLayer instance] userAnswerService] create:userAnswer];
    [subject subscribeNext:^(id x) {
        // Mark userAnswer as synchronized
        for (int i = 0; i < [[_round userAnswers] count]; i++) {
            UserAnswer* ua = [[_round userAnswers] objectAtIndex:i];
            if ([ua isEqual:x]) {
                ua = x;
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                ua.synchronized = true;
                [realm commitWriteTransaction];
            }
        }
    } error:^(NSError *error) {
        NSLog(@"Answer synchronize failed: %@", [error localizedDescription]);
    } completed:^{
        NSLog(@"Answer synchronized");
    }];
    
    User* relatedUser = [_round nextMoveUser];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    relatedUser.totalIncorrectAnswers++;
    [realm commitWriteTransaction];
    
    _currentQuestionIndex++;
    [self showNextQuestion];
}

- (void)showNextQuestion {
    if (_currentQuestionIndex < 3) {
        Question* q = [_questionViewModel questionForQuestionIndex:_currentQuestionIndex onTheme:_selectedTheme inRound:_round];
        // create empty unsynchronized userAnswer
        
        UserAnswer* ua = [[UserAnswer alloc] init];
        // generating new primary key. will be replaced after creating on server side
        long long newID = [[[ServiceLayer instance] userAnswerService] getNextPrimaryKey];
        
        ua.ID = newID;
        ua.relatedAnswer = [Answer emptyAnswer];
        ua.relatedUser = [Player instance];
        ua.relatedRound = _round;
        ua.relatedQuestion = q;
        ua.secForAnswer = QUESTION_TIMEOUT_INTERVAL;
        ua.synchronized = NO;
        
        
        // Persist unsynchronized UserAnswer
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        // Error, while trying to add existing Nested objects (User, Question, Answer etc.)
        [realm addOrUpdateObject:ua];
//        [[_round userAnswers] addObject:ua];
        [realm commitWriteTransaction];
        
        self.secondsRemain = 30.0;
        
        // Start 30 seconds timer
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            _questionTimer = [NSTimer scheduledTimerWithTimeInterval:30 repeats:NO block:^(NSTimer * _Nonnull timer) {
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
            _timeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
                _secondsRemain -= 0.1;
                
                // Update UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString* secondsRemain = [NSString stringWithFormat:@"%2.1f", self.secondsRemain];
                    [_timeElapsedLabel setText:secondsRemain];
                });
            }];
            [[NSRunLoop currentRunLoop] addTimer:_timeTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
        
        
        
        
        
//        // start async timer
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            _questionTimer = [NSTimer scheduledTimerWithTimeInterval:QUESTION_TIMEOUT_INTERVAL
//                                                       target:self
//                                                     selector:@selector(timeElapsed)
//                                                     userInfo:nil
//                                                      repeats:NO];
//            self.secondsRemain = QUESTION_TIMEOUT_INTERVAL;
//            // update label with timer
//            _timeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSecondsRemain) userInfo:nil repeats:YES];
//        });
        
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
        NSMutableArray* signalsArray = [[NSMutableArray alloc] init];
        for (UserAnswer* ua in [_questionViewModel lastPlayerUserAnswersForRound:_round]) {
            RACSignal* signal = [[[ServiceLayer instance] userAnswerService] create:ua];
            [signalsArray addObject:signal];
        }
        
        RACSignal *sig = [RACSignal concat:[signalsArray.rac_sequence map:^id(id value) {
            return value;
        }]];
        
        [sig subscribeNext:^(id x) {
            // Mark userAnswer as synchronized
            for (UserAnswer* ua in [_round userAnswers]) {
                if ([ua isEqual:x]) {
                    ua.synchronized = true;
                    NSLog(@"Answer synchronized");
                }
            }
        } error:^(NSError *error) {
            NSLog(@"Error udpating ua");
            // pop
            [self popToMatchViewController];
        } completed:^{
            RACReplaySubject* subject = [[[ServiceLayer instance] userService] obtainWithAccessToken:[[[ServiceLayer instance] authorizationService] accessToken]];
            [subject subscribeNext:^(id x) {
                [Player setPlayer:x];
            } error:^(NSError *error) {
                [self popToMatchViewController];
            } completed:^{
                [self popToMatchViewController];
            }];
        }];
    }
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
    Match *m = [_questionViewModel matchForRound:_round];
    [destVC.matchViewModel setMatch:m];
    [destVC.tableView reloadData];
    [[self navigationController] popToViewController:destVC animated:YES];

}

- (void)updateSecondsRemain {
    self.secondsRemain -= 0.1;
    NSString* secondsRemain = [NSString stringWithFormat:@"%2.1f", self.secondsRemain];
    [_timeElapsedLabel setText:secondsRemain];
}

@end
