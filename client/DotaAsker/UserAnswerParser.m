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

+ (UserAnswer*)parse:(NSData *)JSONData {
    NSError *error;
    if(!JSONData)
        return nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:&error];
    if (error) {
        return nil;
    }
    else {
        if ([[dict objectForKey:@"COMMAND"] isEqual: @"ERROR"]) {
            NSLog(@"Parsing error: %@", [dict objectForKey:@"REASON"]);
            return nil;
        }
        UserAnswer* userAnswer = [[UserAnswer alloc] init];
        if (!([dict objectForKey:@"id"] && [dict objectForKey:@"round_id"] && [dict objectForKey:@"question_id"] &&
              [dict objectForKey:@"user_id"] && [dict objectForKey:@"answer_id"])) {
            NSLog(@"Parsing error: can't retrieve a field");
            return nil;
        }
        userAnswer.ID = [[dict objectForKey:@"id"] longValue];
        userAnswer.relatedRoundID = [[dict objectForKey:@"round_id"] longValue];
        userAnswer.relatedUserID = [[dict objectForKey:@"user_id"] longValue];
        userAnswer.relatedAnswerID = [[dict objectForKey:@"answer_id"] longValue];
        userAnswer.relatedQuestionID = [[dict objectForKey:@"question_id"] longValue];
        return userAnswer;
    }
}

+ (NSData*)encode:(UserAnswer*)userAnswer {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"COMMAND", @"REMOVE",
                          @"ENTITY", @"USERANSWER",
                          @"id", [userAnswer ID],
                          @"round_id", [userAnswer relatedRoundID],
                          @"question_id", [userAnswer relatedQuestionID],
                          @"user_id", [userAnswer relatedUserID],
                          @"answer_id", [userAnswer relatedAnswerID],
                          nil];
    NSError* err;
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&err];
    if(err) {
        data = nil;
    }
    return data;
}

@end
