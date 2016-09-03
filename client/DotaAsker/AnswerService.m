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


- (id)init {
    self = [super init];
    return self;
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
