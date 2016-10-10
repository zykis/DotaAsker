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
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
#import "Match.h"

@implementation MatchService

@synthesize transport = _transport;

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


@end
