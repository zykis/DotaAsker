//
//  AnswerService.m
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AnswerService.h"
#import "QuestionService.h"
#import "AnswerParser.h"
#import "AnswerTransport.h"

@implementation AnswerService

@synthesize transport;
@synthesize parser;
@synthesize cache;

- (id)init {
    self = [super init];
    if(self) {
        parser = [[AnswerParser alloc] init];
        cache = [[AbstractCache alloc] init];
        transport = [[AnswerTransport alloc] init];
    }
    return self;
}

- (Answer*)answerAtIndex:(NSInteger)index ofQuestion:(Question*)question {
    NSArray* answers = [self answersForQuestion:question];
    Answer* ans = [answers objectAtIndex:index];
    return ans;
}

- (NSArray*)answersForQuestion:(Question *)question {
    NSMutableArray* answers = [[NSMutableArray alloc] init];
    for (int i = 0; i < [[question answersIDs] count]; i++) {
        Answer* ans = [self obtain:[[[question answersIDs] objectAtIndex:i] integerValue]];
        [answers addObject:ans];
    }
    return answers;
}

- (Answer*)correctAnswerForQuestion:(Question *)question {
    NSArray* answers = [self answersForQuestion:question];
    for (int i = 0; i < [answers count]; i++) {
        if([[answers objectAtIndex:i] isCorrect]) {
            return [answers objectAtIndex:i];
        }
    }
    return nil;
}

+ (AnswerService*)instance {
    static AnswerService *answerService = nil;
    @synchronized(self) {
        if(answerService == nil)
            answerService = [[self alloc] init];
    }
    return answerService;
}

@end
