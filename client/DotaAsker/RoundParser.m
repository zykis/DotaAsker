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
#import "UserParser.h"

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
    //Next Move user
    NSDictionary* userDict = [JSONDict objectForKey:@"next_move_user"];
    User* nextMoveUser = [UserParser parse:userDict andChildren:NO];
    //may be nil
    if (nextMoveUser)
        [round setNextMoveUser: nextMoveUser];
    
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
        [[round userAnswers] addObject:ua];
    }
    return round;
}

+ (NSDictionary*)encode:(Round *)round {
    NSMutableDictionary *dict = [[NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedLongLong:[round ID]], @"id",
            nil] mutableCopy];
    
    NSDictionary* userDict = [UserParser encode:[round nextMoveUser]];
    if (![userDict isEqual:[NSNull null]])
        [dict setObject:userDict forKey:@"next_move_user"];
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    return data;
}

@end
