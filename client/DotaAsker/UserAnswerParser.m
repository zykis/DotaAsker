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
    if (!([JSONDict objectForKey:@"ID"] &&
          [JSONDict objectForKey:@"ROUND_ID"] &&
          [JSONDict objectForKey:@"USER_ID"] &&
          [JSONDict objectForKey:@"ANSWER_ID"] &&
          [JSONDict objectForKey:@"QUESTION_ID"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field");
        return nil;
    }
    
    UserAnswer* userAnswer = [[UserAnswer alloc] init];
    userAnswer.ID = [[JSONDict objectForKey:@"id"] longValue];
    userAnswer.relatedRoundID = [[JSONDict objectForKey:@"round_id"] longValue];
    userAnswer.relatedUserID = [[JSONDict objectForKey:@"user_id"] longValue];
    userAnswer.relatedAnswerID = [[JSONDict objectForKey:@"answer_id"] longValue];
    userAnswer.relatedQuestionID = [[JSONDict objectForKey:@"question_id"] longValue];
    return userAnswer;
}

+ (NSDictionary*)encode:(UserAnswer*)userAnswer {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"COMMAND", @"REMOVE",
                          @"ENTITY", @"USERANSWER",
                          @"ID", [userAnswer ID],
                          @"ROUND_ID", [userAnswer relatedRoundID],
                          @"QUESTION_ID", [userAnswer relatedQuestionID],
                          @"USER_ID", [userAnswer relatedUserID],
                          @"ANSWER_ID", [userAnswer relatedAnswerID],
                          nil];
    return dict;
}

@end
