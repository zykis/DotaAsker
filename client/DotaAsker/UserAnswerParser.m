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

- (UserAnswer*)parse:(NSDictionary *)JSONDict {
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
    userAnswer.ID = [[JSONDict objectForKey:@"ID"] longValue];
    userAnswer.relatedRoundID = [[JSONDict objectForKey:@"ROUND_ID"] longValue];
    userAnswer.relatedUserID = [[JSONDict objectForKey:@"USER_ID"] longValue];
    userAnswer.relatedAnswerID = [[JSONDict objectForKey:@"ANSWER_ID"] longValue];
    userAnswer.relatedQuestionID = [[JSONDict objectForKey:@"QUESTION_ID"] longValue];
    return userAnswer;
}

- (NSDictionary*)encode:(UserAnswer*)userAnswer {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"ID", [userAnswer ID],
                          @"ROUND_ID", [userAnswer relatedRoundID],
                          @"QUESTION_ID", [userAnswer relatedQuestionID],
                          @"USER_ID", [userAnswer relatedUserID],
                          @"ANSWER_ID", [userAnswer relatedAnswerID],
                          nil];
    return dict;
}

@end
