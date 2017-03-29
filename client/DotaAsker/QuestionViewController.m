//
//  QuestionViewController.m
//  DotaAsker
//
//  Created by Artem on 19/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

// Local
#import "QuestionViewController.h"
#import "MatchViewController.h"
#import "ServiceLayer.h"
#import "QuestionViewModel.h"
#import "MatchViewModel.h"
#import "Helper.h"
#import "Answer.h"
#import "UIViewController+Utils.h"
#import "ModalLoadingView.h"
#import "Helper.h"

// Libraries
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>
#import <Realm/Realm.h>

#define QUESTION_TIMEOUT_INTERVAL 10


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

- (void)blockUI {
    [_answer1Button setEnabled:NO];
    [_answer2Button setEnabled:NO];
    [_answer3Button setEnabled:NO];
    [_answer4Button setEnabled:NO];
}

- (void)unblockUI {
    [_answer1Button setEnabled:YES];
    [_answer2Button setEnabled:YES];
    [_answer3Button setEnabled:YES];
    [_answer4Button setEnabled:YES];
}

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
    
    _questionImageView.clipsToBounds = YES;
    _progressView.layer.borderWidth = 1;
    _progressView.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    [_progressView setProgress:1.0];
    [self createEmptyAnswers];
}

- (void)viewWillAppear:(BOOL)animated {
    [self blockUI];
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self showNextQuestion];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(pauseApp) 
        name:@"UIApplicationDidEnterBackgroundNotification"
        object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(resumeApp) 
        name:@"UIApplicationDidBecomeActiveNotification"
        object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIApplicationDidEnterBackgroundNotification"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIApplicationDidBecomeActiveNotification"
                                                  object:nil];
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
    UserAnswer* userAnswer = [[[UserAnswer objectsWhere:@"relatedRoundID == %lld AND relatedUserID == %lld", [self selectedRound].ID, [Player instance].ID] sortedResultsUsingKeyPath:@"createdOn" ascending:YES] objectAtIndex:_currentQuestionIndex];
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
    // Invalidate timers
    if (_timeTimer) {
        [_timeTimer invalidate];
        _timeTimer = nil;
    }
    if (_questionTimer) {
        [_questionTimer invalidate];
        _questionTimer = nil;
    }

    UserAnswer *userAnswer = [[[self selectedRound] userAnswers] objectAtIndex:_currentQuestionIndex];
    assert(userAnswer);

    User* relatedUser = [[self selectedRound] nextMoveUser];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    relatedUser.totalIncorrectAnswers++;
    [realm commitWriteTransaction];
    
    _currentQuestionIndex++;
    [self showNextQuestion];
}

- (void)createEmptyAnswers {
    for (int i = 0; i < 3; i++) {
        Question* q = [_questionViewModel questionForQuestionIndex:i
                                          onTheme:[self selectedTheme]
                                          inRound:[self selectedRound]];
        // create empty modified userAnswer
        UserAnswer* ua = [[UserAnswer alloc] init];
        // generating new primary key. will be replaced after creating on server side
        long long newID = [[[ServiceLayer instance] userAnswerService] getNextPrimaryKey];
        
        ua.ID = newID;
        ua.relatedAnswerID = [Answer emptyAnswer].ID;
        ua.relatedUserID = [Player instance].ID;
        ua.relatedRoundID = [self selectedRound].ID;
        ua.relatedQuestionID = q.ID;
        ua.secForAnswer = QUESTION_TIMEOUT_INTERVAL;
        ua.modified = YES;
        
        // Persist modified UserAnswer
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [[[self selectedRound] userAnswers] addObject:ua];
        [realm commitWriteTransaction];
        self.secondsRemain = QUESTION_TIMEOUT_INTERVAL;
    }
}

- (void)showNextQuestion {
    NSInteger totalUserAnswersCount = [[UserAnswer allObjects] count];
    assert((totalUserAnswersCount % 3) == 0);
    if (_currentQuestionIndex < 3) {
        Question* q = [_questionViewModel questionForQuestionIndex:_currentQuestionIndex
                                                           onTheme:[self selectedTheme]
                                                           inRound:[self selectedRound]];
        // Start 30 seconds timer
        [self startTimersWithExpirationInterval: QUESTION_TIMEOUT_INTERVAL andProgressUpdateInterval: 0.01];
        
        assert(q);
        RLMArray<Answer>* answers = [q answers];
        
        CGSize size = [[Helper shared] getQuestionImageViewSize];
        [_questionImageView setImage:nil];
        RACReplaySubject* subject = [[[ServiceLayer instance] questionService] obtainImageForQuestion:q withWidth:size.width andHeight:size.height];
        [subject subscribeNext:^(id x) {
            [_questionImageView setImage:x];
        } error:^(NSError *error) {
            UIImage* defaultImage = [UIImage imageNamed:@"default.png"];
            CGSize newSize = [_questionimageView bounds].size;
            UIImage* resizedDefaultImage = [Helper imageWithImage:defaultImage scaledToSize:newSize];
            [_questionImageView setImage:resizedDefaultImage];
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
        [self unblockUI];
    }
    //Игрок ответил на все вопросы
    else {
        [self blockUI];
        // Present LoadingView
        __block ModalLoadingView* loadingView = [[ModalLoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50) andMessage:@"Sending answers"];
        [[[UIApplication sharedApplication] keyWindow] addSubview:loadingView];
        
        void (^errorBlock)(NSError* _Nonnull error) = ^void(NSError* _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentAlertControllerWithMessage:[error localizedDescription]];
                [loadingView removeFromSuperview];
                [self popToMatchViewController];
            });
        };
        
        void (^completeBlock)() = ^void() {
            // UserAnswers has been updated.
            // Updaing Player and tableView
            [loadingView setMessage:@"Getting player"];
            RACReplaySubject* subject = [[[ServiceLayer instance] userService] obtainWithAccessToken:[[[ServiceLayer instance] authorizationService] accessToken]];
            [subject subscribeNext:^(id u) {
                [Player manualUpdate:u];
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
        };
    
        [Player synchronizeWithErrorBlock:errorBlock completionBlock:completeBlock];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat fixedWidth = _questionText.frame.size.width;
    CGSize newSize = [_questionText sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = CGRectMake(_questionText.frame.origin.x,
                                 _questionText.frame.origin.y + _questionText.frame.size.height - newSize.height,
                                 fixedWidth,
                                 newSize.height);
    [_questionText setFrame:newFrame];
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self timeElapsed];
                });
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
    double intervalInSeconds = ABS([pauseDate timeIntervalSinceNow]);
    _secondsRemain = MAX(_secondsRemain - intervalInSeconds, 0);
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
