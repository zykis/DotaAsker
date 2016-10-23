//
//  RoundParser.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "RoundParser.h"
#import "Round.h"
#import "Theme.h"
#import "ThemeParser.h"
#import "QuestionParser.h"
#import "UserAnswerParser.h"
#import "UserAnswer.h"
#import "Player.h"
#import "Question.h"
#import "Answer.h"

@implementation RoundParser

+ (Round*)parse:(NSDictionary *)JSONDict andChildren:(BOOL)bParseChildren {
    if (!([JSONDict objectForKey:@"id"] &&
          [JSONDict objectForKey:@"questions"] &&
          [JSONDict objectForKey:@"user_answers"] &&
          [JSONDict objectForKey:@"next_move_user"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field in RoundParser");
        return nil;
    }
    
    Round* round = [[Round alloc] init];
    //id
    [round setID:[[JSONDict objectForKey:@"id"] unsignedLongLongValue]];
    //Next Move user ID
    NSUInteger nextMoveUserID;
    if ([[JSONDict objectForKey:@"next_move_user"] isEqual:[NSNull null]])
        nextMoveUserID = 0;
    else
        nextMoveUserID = [[JSONDict objectForKey:@"next_move_user"] unsignedLongLongValue];
    [round setNextMoveUserID: nextMoveUserID];
    
    //questions
    NSMutableArray* questionsDict = [JSONDict objectForKey:@"questions"];
    for (NSDictionary* questionDict in questionsDict) {
        Question* q = [QuestionParser parse:questionDict];
        [[round questions] addObject:q];
    }

    //user_answers
    NSArray* user_answersDict = [JSONDict objectForKey:@"user_answers"];
    for (NSDictionary* uaDict in user_answersDict) {
        UserAnswer* ua = [UserAnswerParser parse:uaDict];
        ua.relatedRound = round;
        for (Question* q in [round questions]) {
            for (Answer* a in q.answers) {
                [a setRelatedQuestion:q];
                if(a.ID == ua.relatedAnswerID)
                    ua.relatedAnswer = a;
            }
        }
        [[round userAnswers] addObject:ua];
    }
    return round;
}

@end
