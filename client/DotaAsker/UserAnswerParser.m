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
#import "Round.h"
#import "User.h"
#import "Answer.h"

@implementation UserAnswerParser

+ (UserAnswer*)parse:(NSDictionary *)JSONDict {
    if (!([JSONDict objectForKey:@"id"] &&
          [JSONDict objectForKey:@"user"] &&
          [JSONDict objectForKey:@"answer"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field");
        return nil;
    }
    
    UserAnswer* userAnswer = [[UserAnswer alloc] init];
    userAnswer.ID = [[JSONDict objectForKey:@"id"] longValue];
    NSDictionary* userDict = [JSONDict objectForKey:@"user"];
    userAnswer.relatedUser = [UserParser parse:userDict andChildren:NO];
    NSDictionary* answerDict = [JSONDict objectForKey:@"answer"];
    userAnswer.relatedAnswer = [AnswerParser parse:answerDict];
    return userAnswer;
}

+ (NSData*)encode:(UserAnswer*)userAnswer {
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                          [NSNumber numberWithUnsignedLongLong:[userAnswer relatedRound].ID], @"round",
//                          [NSNumber numberWithUnsignedLongLong:[userAnswer relatedUser].ID], @"user",
//                          [NSNumber numberWithUnsignedLongLong:[userAnswer relatedAnswer].ID], @"answer",
//                          nil];
    NSDictionary* roundDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLongLong:[userAnswer relatedRound].ID] forKey:@"id"];
    NSDictionary* userDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLongLong:[userAnswer relatedUser].ID] forKey:@"id"];
    NSDictionary* answerDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLongLong:[userAnswer relatedAnswer].ID] forKey:@"id"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          roundDict, @"round",
                          userDict, @"user",
                          answerDict, @"answer",
                          nil];
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    return data;
}

@end
