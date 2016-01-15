//
//  RoundParser.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "RoundParser.h"
#import "Round.h"

@implementation RoundParser

- (Round*)parse:(NSDictionary *)JSONDict {
    if (!([JSONDict objectForKey:@"ID"] &&
          [JSONDict objectForKey:@"STATE"] &&
          [JSONDict objectForKey:@"THEME_ID"] &&
          [JSONDict objectForKey:@"QUESTIONS_IDS"] &&
          [JSONDict objectForKey:@"ANSWERS_PLAYER_IDS"] &&
          [JSONDict objectForKey:@"ANSWERS_OPPONENT_IDS"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field");
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
    NSMutableArray* answersPlayerIDs = [JSONDict objectForKey:@"ANSWERS_PLAYER_IDS"];
    [round setAnswersPlayerIDs:answersPlayerIDs];
    //answersOpponentIDs
    NSMutableArray* answersOpponentIDs = [JSONDict objectForKey:@"ANSWERS_OPPONENT_IDS"];
    [round setAnswersOpponentIDs:answersOpponentIDs];

    return round;
}

@end
