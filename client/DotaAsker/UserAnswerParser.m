//
//  UserAnswerParser.m
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "UserAnswerParser.h"
#import "UserAnswer.h"
#import "UserParser.h"
#import "RoundParser.h"
#import "AnswerParser.h"
#import "QuestionParser.h"
#import "Round.h"
#import "User.h"
#import "Answer.h"
#import "Question.h"

@implementation UserAnswerParser

+ (UserAnswer*)parse:(NSDictionary *)JSONDict {
    if (!([JSONDict objectForKey:@"id"] &&
          [JSONDict objectForKey:@"user"] &&
          [JSONDict objectForKey:@"question"] &&
          [JSONDict objectForKey:@"sec_for_answer"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field");
        return nil;
    }
    
    UserAnswer* userAnswer = [[UserAnswer alloc] init];
    
    // ID
    userAnswer.ID = [[JSONDict objectForKey:@"id"] longValue];
    // sec_for_answer
    userAnswer.secForAnswer = [[JSONDict objectForKey:@"sec_for_answer"] integerValue];
    // user
    NSDictionary* userDict = [JSONDict objectForKey:@"user"];
    userAnswer.relatedUser = [UserParser parse:userDict andChildren:NO];
    // answer
    if (![JSONDict[@"answer"] isEqual: [NSNull null]]) {
        NSDictionary* answerDict = [JSONDict objectForKey:@"answer"];
        userAnswer.relatedAnswer = [AnswerParser parse:answerDict];
    }
    else {
        userAnswer.relatedAnswer = [Answer emptyAnswer];
    }
    // round
    userAnswer.relatedRound = [RoundParser parse:[JSONDict objectForKey:@"round"] andChildren:NO];
    
    // question
    userAnswer.relatedQuestion = [QuestionParser parse:[JSONDict objectForKey:@"question"]];
    
    return userAnswer;
}

+ (NSData*)encode:(UserAnswer*)userAnswer {

    NSDictionary* roundDict = [RoundParser encode:[userAnswer relatedRound]];
    NSDictionary* userDict = [UserParser encode:[userAnswer relatedUser]];
    NSDictionary* answerDict = [AnswerParser encode:[userAnswer relatedAnswer]];
    NSDictionary* questionDict = [QuestionParser encode:[userAnswer relatedQuestion]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithUnsignedLongLong:userAnswer.ID], @"id",
                          roundDict, @"round",
                          userDict, @"user",
                          questionDict, @"question",
                          answerDict, @"answer",
                          [NSNumber numberWithUnsignedInteger: userAnswer.secForAnswer], @"sec_for_answer",
                          nil];
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    return data;
}

@end
