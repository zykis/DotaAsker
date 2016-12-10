//
//  UserAnswerService.m
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "UserAnswerService.h"
#import "AnswerService.h"
#import "UserAnswerParser.h"
#import "UserAnswer.h"
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>
#import "UserAnswerTransport.h"
#import "UserAnswerParser.h"

@implementation UserAnswerService

- (id)init {
    self = [super init];
    if (self) {
        _transport = [[UserAnswerTransport alloc] init];
    }
    return self;
}

- (RACReplaySubject*)create:(id)entity {
    RACReplaySubject* subject = [[RACReplaySubject alloc] init];
    NSData* uaData = [UserAnswerParser encode:entity];
    assert(uaData);
    [[_transport create:uaData] subscribeNext:^(id x) {
        UserAnswer* ua = [UserAnswerParser parse:x];
        [subject sendNext:ua];
    } error:^(NSError *error) {
        [subject sendError:error];
    } completed:^{
        [subject sendCompleted];
    }];
    return subject;
}

@end
