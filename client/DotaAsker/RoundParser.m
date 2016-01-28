//
//  RoundParser.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "RoundParser.h"
#import "UserAnswerService.h"
#import "UserService.h"
#import "MatchService.h"
#import "Round.h"

@implementation RoundParser

- (Round*)parse:(NSDictionary *)JSONDict {
    if (!([JSONDict objectForKey:@"ID"] &&
          [JSONDict objectForKey:@"STATE"] &&
          [JSONDict objectForKey:@"THEME_ID"] &&
          [JSONDict objectForKey:@"QUESTIONS_IDS"] &&
          [JSONDict objectForKey:@"ANSWERS_IDS"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field in RoundParser");
        return nil;
    }
    
    Round* round = [[Round alloc] init];
    //id
    [round setID:[[JSONDict objectForKey:@"ID"] unsignedLongLongValue]];
    //round state
    Round_State state = (Round_State)[[JSONDict objectForKey:@"STATE"] integerValue];
    [round setRound_state:state];
    //themeID
    unsigned long long themeID = [[JSONDict objectForKey:@"THEME_ID"] unsignedLongLongValue];
    [round setThemeID:themeID];
    //questionsIDs
    NSMutableArray* questionsIDs = [JSONDict objectForKey:@"QUESTIONS_IDS"];
    [round setQuestionsIDs:questionsIDs];
    //answersPlayerIDs
    
    NSMutableArray* answersIDs = [JSONDict objectForKey:@"ANSWERS_IDS"];
    for (int i = 0; i < [answersIDs count]; i++) {
        unsigned long long uaID = [[answersIDs objectAtIndex:i] unsignedLongLongValue];
        UserAnswer* ua = [[UserAnswerService instance] obtain:uaID];
        if (ua.relatedUserID == [[[UserService instance] player] ID]) {
            [[round answersPlayerIDs] addObject:[NSNumber numberWithUnsignedLongLong:uaID]];
        }
        else {
            [[round answersOpponentIDs] addObject:[NSNumber numberWithUnsignedLongLong:uaID]];
        }
    }

    return round;
}

- (NSDictionary*)encode:(Round*)round {
    Match* m = [[MatchService instance] matchForRound:round];
    NSArray* answers = [round.answersOpponentIDs arrayByAddingObjectsFromArray:round.answersPlayerIDs];
    NSDictionary* jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedLongLong: round.ID], @"ID",
                              [NSNumber numberWithInt: (int)round.round_state], @"STATE",
                              [NSNumber numberWithUnsignedLongLong: round.themeID], @"THEME_ID",
                              [NSNumber numberWithUnsignedLongLong: m.ID], @"MATCH_ID",
                              round.questionsIDs, @"QUESTIONS_IDS",
                              answers, @"ANSWERS_IDS",
                              nil];
    return jsonDict;
}

@end
