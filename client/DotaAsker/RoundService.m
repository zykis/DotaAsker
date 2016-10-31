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
#import "RoundTransport.h"
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>

@implementation RoundService

@synthesize transport = _transport;

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
    if (match.state != MATCH_RUNNING) {
        int index = 0;
        for (Round* r in match.rounds) {
            if ([[r userAnswers] count] == 6) {
                index++;
            }
        }
        if (index == 6) index--;
        return [match.rounds objectAtIndex:index];
    }
    int i;
    for (i = 0; i < [[match rounds] count]; i++) {
        Round* r = [[match rounds] objectAtIndex:i];
        if ([[r userAnswers] count] != QUESTIONS_IN_ROUND * 2)
            break;
    }
    if (i == 6) i--;
    
    return [[match rounds] objectAtIndex:i];
}

- (Theme*)themeSelectedForRound:(Round *)round {
    Theme* selectedTheme;
    for (UserAnswer* ua in [round userAnswers]) {
        for (Question* q in [round questions]) {
            for (Answer* a in [q answers]) {
                if ([a isEqual:[ua relatedAnswer]]) {
                    return [q theme];
                }
            }
        }
    }
    return selectedTheme;
}

- (NSArray*)themesForRound:(Round *)round {
    NSMutableArray* themes = [[NSMutableArray alloc] init];
    for (Question* q in [round questions]) {
        Theme* t = [q theme];
        if (![themes containsObject:t]) {
            [themes addObject:t];
        }
    }
    NSArray* immutableThemes = [NSArray arrayWithArray:themes];
    return immutableThemes;
}

- (Question*)questionAtIndex:(NSUInteger)index onTheme:(Theme *)theme inRound:(Round*)round {
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
