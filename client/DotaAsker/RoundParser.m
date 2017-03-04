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
    if (!([JSONDict objectForKey:@"id"])) {
        NSLog(@"Parsing error: can't retrieve a field in RoundParser");
        return nil;
    }
    
    Round* round = [[Round alloc] init];
    //id
    [round setID:[[JSONDict objectForKey:@"id"] unsignedLongLongValue]];
    
    // Next Move user
    if ([[JSONDict allKeys] containsObject:@"next_move_user"]) {
        NSDictionary* userDict = [JSONDict objectForKey:@"next_move_user"];
        User* nextMoveUser = [UserParser parse:userDict andChildren:NO];
        
        //may be nil
        [round setNextMoveUserID: nextMoveUser.ID];
    }
    
    //questions
    if ([[JSONDict allKeys] containsObject:@"questions"]) {
        NSMutableArray* questionsDict = [JSONDict objectForKey:@"questions"];
        for (NSDictionary* questionDict in questionsDict) {
            Question* q = [QuestionParser parse:questionDict];
            Question* existingQuestion = [Question objectForPrimaryKey:@(q.ID)];
            if (existingQuestion != nil) {
                [[round questions] addObject:existingQuestion];
            }
            else {
                [[round questions] addObject:q];
            }
        }
        assert([[round questions] count] == 9);
    }

    //user_answers
    if ([[JSONDict allKeys] containsObject:@"user_answers"]) {
        NSArray* user_answersDict = [JSONDict objectForKey:@"user_answers"];
        for (NSDictionary* uaDict in user_answersDict) {
            UserAnswer* ua = [UserAnswerParser parse:uaDict];
            [[round userAnswers] addObject:ua];
        }
        assert([[round userAnswers] count] <= 36);
    }
    
    if (![JSONDict[@"selected_theme"] isEqual: [NSNull null]]) {
        Theme* selected_theme = [ThemeParser parse:JSONDict[@"selected_theme"]];
        [round setSelectedTheme:selected_theme];
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
    else
        [dict setObject:[NSNull null] forKey:@"next_move_user"];
    
    if ([round selectedTheme]) {
        NSDictionary* themeDict = [ThemeParser encode: [round selectedTheme]];
        [dict setObject:themeDict forKey:@"selected_theme"];
    }
    return dict;
}

@end
