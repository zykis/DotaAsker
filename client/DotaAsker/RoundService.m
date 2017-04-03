//
//  RoundService.m
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "RoundService.h"
#import "RoundParser.h"
#import "Match.h"
#import "User.h"
#import "Round.h"
#import "UserAnswer.h"
#import "Answer.h"
#import "Question.h"
#import "Player.h"
#import "Theme.h"
#import "RoundTransport.h"
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>

@implementation RoundService

@synthesize transport = _transport;

- (id)init {
    self = [super init];
    if (self) {
        _transport = [[RoundTransport alloc] init];
    }
    return self;
}

- (RACReplaySubject*)update:(id)entity {
    RACReplaySubject* subject = [[RACReplaySubject alloc] init];
    NSDictionary* roundDict = [RoundParser encode:entity];
    NSData *roundData = [NSJSONSerialization dataWithJSONObject:roundDict options:kNilOptions error:nil];
    assert(roundData);
    [[_transport update:roundData] subscribeNext:^(id x) {
        Round* r = [RoundParser parse:x andChildren:YES];
        [subject sendNext:r];
    } error:^(NSError *error) {
        [subject sendError:error];
    } completed:^{
        [subject sendCompleted];
    }];
    return subject;
}

- (Round*)currentRoundforMatch:(Match *)match {
    // Текущий раунд для матча
    // Если состояние матча TIME_ELAPSED или MATCH_RUNNING, берём индекс раунда,
    // пользовательских ответов в котором меньше 6
    // Иначе, если состояние матча - MATCH_FINISHED, берём индекс последнего раунда (5)
    
    int i;
    Round* currentRound;
    if ([match state] == MATCH_RUNNING) {
        for (i = 0; i < ROUNDS_IN_MATCH; i++) {
            if ([[[[match rounds] objectAtIndex:i] userAnswers] count] < QUESTIONS_IN_ROUND * 2)
                break;
        }
        currentRound = [[match rounds] objectAtIndex:i];
    }
    else {
        currentRound = [[match rounds] lastObject];
    }
    
    return currentRound;
}

- (Theme*)themeSelectedForRound:(Round *)round {
    return [round selectedTheme];
}

- (NSArray*)themesForRound:(Round *)round {
    NSMutableArray* themes = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [[round questions] count]; i++) {
        Question* q = [[round questions] objectAtIndex:i];
        Theme* t = [q theme];
        if (![themes containsObject:t]) {
            [themes addObject:t];
        }
    }
    NSArray* immutableThemes = [NSArray arrayWithArray:themes];
    return immutableThemes;
}

- (Question*)questionAtIndex:(NSUInteger)index onTheme:(Theme*)theme inRound:(Round*)round {
    NSUInteger i = 0;
    for (Question* q in [round questions]) {
        if ([[q theme] isEqual:theme]) {
            if (index == i) {
                return q;
            }
            else {
                i++;
            }
        }
    }
    return NULL;
}

- (void)updateRoundsWithNext:(void (^)(Round* x))nextBlock error:(void (^)(NSError* error))errorBlock complete:(void(^)())completeBlock {
    dispatch_time_t timeoutTime = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __block BOOL obtained = NO;
        RLMResults<Round*>* modifiedRounds = [Round objectsWhere:@"modified == YES"];
        for (Round* r in modifiedRounds) {
            // Create Round
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            RACSignal* sig = [self update:r];
            [sig subscribeNext:^(id  _Nullable x) {
                nextBlock(x);
                obtained = YES;
                } error:^(NSError * _Nullable error) {
                    dispatch_semaphore_signal(semaphore);
                    if ([error code] == 404) {
                        NSLog(@"No rounds with id: %lld found in server", r.ID);
                        obtained = YES;
                    }
                } completed:^{
                    dispatch_semaphore_signal(semaphore);
                }];
            if (dispatch_semaphore_wait(semaphore, timeoutTime)) {
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The operation timed out.", nil),
                    NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Have you tried turning it off and on again?", nil)
                };
                NSError *error = [NSError errorWithDomain:@"com.zykis.dotaasker"
                                                    code:-59
                                                userInfo:userInfo];
                errorBlock(error);
                return;
            }
            if (!obtained) {
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The operation timed out.", nil),
                    NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Have you tried turning it off and on again?", nil)
                };
                NSError *error = [NSError errorWithDomain:@"com.zykis.dotaasker"
                                                    code:-60
                                                userInfo:userInfo];
                errorBlock(error);
                return;
            }
            obtained = NO;
        }
        
        completeBlock();
    });
}

@end
