//
//  QuestionService.m
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "QuestionService.h"
#import "ThemeService.h"
#import "QuestionParser.h"
#import "QuestionTransport.h"
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>
@import UIKit;

@implementation QuestionService

@synthesize transport = _transport;

- (id)init {
    self = [super init];
    if(self) {
        _transport = [[QuestionTransport alloc] init];
    }
    return self;
}

- (RACReplaySubject*)obtainImageForQuestion:(Question *)question withWidth: (NSUInteger)width andHeight: (NSUInteger)height {
    RACReplaySubject* subject = [[RACReplaySubject alloc] init];
    RACReplaySubject* sub = [_transport obtainImageForQuestion:question withWidth:width andHeight:height];
    [sub subscribeNext:^(id x) {
        UIImage *image = x;
        [subject sendNext:image];
    } error:^(NSError *error) {
        [subject sendError:error];
    } completed:^{
        [subject sendCompleted];
    }];
    return subject;
}

- (RACReplaySubject*)submitQuestion:(Question *)question {
    RACReplaySubject* subject = [[RACReplaySubject alloc] init];
    NSDictionary* qDict = [QuestionParser encode:question];
    NSData* qData = [NSJSONSerialization dataWithJSONObject:qDict options:kNilOptions error:nil];
    
    RACReplaySubject* sub = [_transport submitQuestionData:qData];
    [sub subscribeNext:^(id x) {
        [subject sendNext:x];
    } error:^(NSError *error) {
        [subject sendError:error];
    } completed:^{
        [subject sendCompleted];
    }];
    return subject;
}

@end
