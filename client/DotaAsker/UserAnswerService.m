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

- (id)init {
    self = [super init];
    if(self) {
        parser = [[UserAnswerParser alloc] init];
        cache = [[UserAnswerCache alloc] init];
        transport = [[UserAnswerTransport alloc] init];
    }
    return self;
}

- (id)obtain:(NSInteger)ID {
    UserAnswer* userAnswer = [cache obtain:ID];
    if (userAnswer == nil) {
        NSData* JSONData = [transport obtain:ID];
        userAnswer = [UserAnswerParser parse:JSONData];
        if (userAnswer != nil) {
            [cache append:userAnswer];
        }
    }
    return userAnswer;
}

- (NSArray*)obtainAll {
    NSArray* array = [transport obtainAll];
    return array;
}

- (void)update:(UserAnswer *)userAnswer {
    [cache update:userAnswer];
    [transport update:userAnswer];
}

- (void)remove:(NSInteger)entityID {
    [cache remove:entityID];
    [transport remove:entityID];
}

@end
