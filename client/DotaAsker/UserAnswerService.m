//
//  UserAnswerService.m
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "UserAnswerService.h"
#import "AnswerService.h"
#import "UserAnswer.h"

@implementation UserAnswerService

@synthesize parser;
@synthesize cache;
@synthesize transport;

+ (UserAnswerService*)instance {
    static UserAnswerService *userAnswerService = nil;
    @synchronized(self) {
        if(userAnswerService == nil)
            userAnswerService = [[self alloc] init];
    }
    return userAnswerService;
}

- (id)init {
    self = [super init];
    if(self) {
        parser = [[UserAnswerParser alloc] init];
        cache = [[AbstractCache alloc] init];
        transport = [[UserAnswerTransport alloc] init];
    }
    return self;
}

- (NSString*)textForUserAnswer:(UserAnswer *)userAnswer {
    Answer* ans = [[AnswerService instance] obtain:[userAnswer relatedAnswerID]];
    return [ans text];
}

- (BOOL)isCorrect:(UserAnswer *)userAnswer {
    Answer* a = [[AnswerService instance] obtain:userAnswer.relatedAnswerID];
    return [a isCorrect];
}

@end
