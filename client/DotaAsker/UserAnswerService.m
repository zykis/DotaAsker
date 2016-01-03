//
//  UserAnswerService.m
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "UserAnswerService.h"
#import "UserAnswer.h"

@implementation UserAnswerService

@synthesize parser;
@synthesize cache;
@synthesize transport;

-(id)init {
    self = [super init];
    if(self) {
        parser = [[UserAnswerParser alloc] init];
        cache = [[UserAnswerCache alloc] init];
        transport = [[UserAnswerTransport alloc] init];
    }
    return self;
}

-(UserAnswer*)obtain:(NSInteger)ID {
    NSData* JSONData = [transport obtain:ID];
    UserAnswer* userAnswer = [UserAnswerParser parse:JSONData];
    return userAnswer;
}

-(NSArray*)obtainAll {
    NSArray *userAnswers = [[NSArray alloc] init];
    return userAnswers;
}

@end
