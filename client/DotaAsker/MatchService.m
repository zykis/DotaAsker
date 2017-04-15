//
//  MatchService.m
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "MatchService.h"
#import "MatchParser.h"
#import "MatchTransport.h"
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>
#import "Match.h"
#import "UserAnswer.h"
#import "Answer.h"
#import "AuthorizationService.h"

@implementation MatchService

@synthesize transport = _transport;
@synthesize authorizationService = _authorizationService;

- (id)init {
    self = [super init];
    if(self) {
        _transport = [[MatchTransport alloc] init];
    }
    return self;
}

- (RACReplaySubject*)findMatchForUser:(NSString *)accessToken {
    RACReplaySubject* subject = [[RACReplaySubject alloc] init];
    RACSignal* signal = [_transport findMatchForUser:accessToken];
    [signal subscribeNext:^(id x) {
        Match* m = [MatchParser parse:x andChildren:YES];
        [subject sendNext:m];
    } error:^(NSError *error) {
        [subject sendError:error];
    } completed:^{
        [subject sendCompleted];
    }];
    return subject;
}

- (RACReplaySubject*)update:(id)entity {
    RACReplaySubject* subject = [[RACReplaySubject alloc] init];
    NSDictionary* matchDict = [MatchParser encode:entity andChildren:NO];
    NSData *matchData = [NSJSONSerialization dataWithJSONObject:matchDict options:kNilOptions error:nil];
    assert(matchData);
    [[_transport update:matchData] subscribeNext:^(id x) {
        Match* m = [MatchParser parse:x andChildren:YES];
        [subject sendNext:m];
    } error:^(NSError *error) {
        [subject sendError:error];
    } completed:^{
        [subject sendCompleted];
    }];
    return subject;
}

- (RACReplaySubject*)finishMatch:(Match *)match {
    RACReplaySubject* subject = [[RACReplaySubject alloc] init];
    NSDictionary* matchDict = [MatchParser encode:match andChildren:NO];
    NSData *matchData = [NSJSONSerialization dataWithJSONObject:matchDict options:kNilOptions error:nil];
    assert(matchData);
    [[_transport finishMatch:matchData] subscribeNext:^(id x) {
        Match* m = [MatchParser parse:x andChildren:YES];
        [subject sendNext:m];
    } error:^(NSError *error) {
        [subject sendError:error];
    } completed:^{
        [subject sendCompleted];
    }];
    return subject;
}

- (NSUInteger)scoreForMatch:(Match*)m andUser:(User*)u {
    NSUInteger score = 0;
    for (Round* r in [m rounds]) {
        for (UserAnswer* ua in [r userAnswers]) {
            if ([[ua relatedAnswer] isCorrect])
            {
                if([[ua relatedUser] isEqual:u])
                    score++;
            }
        }
    }
    return score;
}

- (User*)nextMoveUserInMatch:(Match *)match {
    NSUInteger i = 0;
    for (Round* r in [match rounds]) {
        if ([[r userAnswers] count] == 6)
            i++;
    }
    User* nextMoveUser  = [[[match rounds] objectAtIndex:i] nextMoveUser];
    assert(nextMoveUser);
    return nextMoveUser;
}

- (RACReplaySubject*)surrendAtMatch: (Match*)match {
    RACReplaySubject* subject = [RACReplaySubject subject];
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedLongLong:match.ID], @"match_id", nil];
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    
    [[_transport surrendAtMatchData:data andAccessToken:[_authorizationService accessToken]] subscribeNext:^(id x) {
        NSLog(@"Surrended");
        [subject sendNext:x];
        [subject sendCompleted];
    } error:^(NSError *error) {
        [subject sendError:error];
        NSLog(@"Error while trying to surrend");
    } completed:^{
        [subject sendCompleted];
    }];
    return subject;
}

- (Winner)winnerAtMatch:(Match*)match {
    if (([match finishReason] == MATCH_FINISH_REASON_SURREND) && (![[match winner] isEqual:[Player instance]]))
        return kOpponent;
    if (([match finishReason] == MATCH_FINISH_REASON_TIME_ELAPSED) && (![[match winner] isEqual:[Player instance]]))
        return kOpponent;
    if ([[match winner] isEqual: [Player instance]])
        return kPlayer;
    else
        return kDraw;
}

@end
