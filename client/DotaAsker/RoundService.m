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
    if ([match state] == MATCH_RUNNING || [match state] == MATCH_TIME_ELAPSED) {
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

@end
