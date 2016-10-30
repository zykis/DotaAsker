//
//  UserAnswerParser.m
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "UserAnswerParser.h"
#import "UserAnswer.h"


@implementation UserAnswerParser

+ (UserAnswer*)parse:(NSDictionary *)JSONDict {
    if (!([JSONDict objectForKey:@"id"] &&
          [JSONDict objectForKey:@"round_id"] &&
          [JSONDict objectForKey:@"user_id"] &&
          [JSONDict objectForKey:@"answer_id"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field");
        return nil;
    }
    
    UserAnswer* userAnswer = [[UserAnswer alloc] init];
    userAnswer.ID = [[JSONDict objectForKey:@"id"] longValue];
    userAnswer.relatedRoundID = [[JSONDict objectForKey:@"round_id"] longValue];
    userAnswer.relatedUserID = [[JSONDict objectForKey:@"user_id"] longValue];
    userAnswer.relatedAnswerID = [[JSONDict objectForKey:@"answer_id"] longValue];
    return userAnswer;
}

+ (NSData*)encode:(UserAnswer*)userAnswer {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithUnsignedLongLong:[userAnswer relatedRoundID]], @"round_id",
                          [NSNumber numberWithUnsignedLongLong:[userAnswer relatedUserID]], @"user_id",
                          [NSNumber numberWithUnsignedLongLong:[userAnswer relatedAnswerID]], @"answer_id",
                          nil];
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    return data;
}

@end
