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
    NSString* message = [NSString stringWithFormat:@"{\"COMMAND\":\"GET\", \"ENTITY\":\"USERANSWER\", \"ID\":%ld}", (long)entityID];
    NSData* JSONData = [[self obtainMessageWithMessage:message] dataUsingEncoding:NSUTF8StringEncoding];
    return JSONData;
}

- (NSArray*)obtainAll {
    NSString* message = [NSString stringWithFormat:@"{\"COMMAND\":\"GET\",\"ENTITY:USERANSWER\"}"];
    NSData* JSONData = [[self obtainMessageWithMessage:message] dataUsingEncoding:NSUTF8StringEncoding];
    NSArray* userAnswers = [[NSMutableArray alloc] initWithObjects:[UserAnswerParser parseAll:JSONData], nil];
    return userAnswers;
}

- (id)update:(id)entity {
    UserAnswer* userAnswer = entity;
    NSString* message = [NSString stringWithFormat:@"{\"COMMAND\":\"UPDATE, \"ENTITY\":\"USERANSWER\", \"ID\":%ld}", (long)[userAnswer ID]];
    NSData* JSONData = [[self obtainMessageWithMessage:message] dataUsingEncoding:NSUTF8StringEncoding];
    UserAnswer* result = [UserAnswerParser parse:JSONData];
    return result;
}

- (void)remove:(NSInteger)entityID {
    NSString* message = [NSString stringWithFormat:@"{\"COMMAND\":\"REMOVE\", \"ENTITY\":\"USERANSWER\", \"ID\":%ld}", (long)entityID];
    [self sendMessage:message];
}

- (void)create:(UserAnswer*)userAnswer {
    NSData* data = [UserAnswerParser encode:userAnswer];
    if(data) {
        NSString* encodedString = [NSString stringWithFormat:@"{\"COMMAND\":\"CREATE\", \"ENTITY\":\"USERANSWER\", \"OBJECT\":%@}", [NSString stringWithUTF8String:[data bytes]]];
        [self sendMessage:encodedString];
    }
}

@end