//
//  UserAnswerTransport.m
//  DotaAsker
//
//  Created by Artem on 17/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "UserAnswerTransport.h"
#import "UserAnswerParser.h"
#import "UserAnswer.h"

@implementation UserAnswerTransport

- (NSData*)obtain:(NSInteger)entityID {
    NSString* message = [NSString stringWithFormat:@"{\"COMMAND\":\"GET\", \"ENTITY\":\"USERANSWER\", \"ID\":%ld}", entityID];
    NSData* JSONData = [self obtainDataWithMessage:message];
    
    
    
    
    return JSONData;
}

- (id)update:(id)entity {
    UserAnswer* userAnswer = entity;
    NSString* message = [NSString stringWithFormat:@"{COMMAND:UPDATE}{ENTITY:USERANSWER}{ID:%ld}, ", [userAnswer ID]];
    NSData* JSONData = [self obtainDataWithMessage:message];
    UserAnswer* result = [UserAnswerParser parse:JSONData];
    return result;
}

- (NSData*)obtainAll {
    NSString* message = [NSString stringWithFormat:@"{COMMAND:GET}{ENTITY:USERANSWER}"];
    NSData* JSONData = [self obtainDataWithMessage:message];
    NSMutableArray* userAnswers = [[NSMutableArray alloc] init];
    [userAnswers addObjectsFromArray: [UserAnswerParser parseAll:JSONData]];
    return userAnswers;
}

@end