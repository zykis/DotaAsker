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

@implementation RoundParser

+ (Round*)parse:(NSDictionary *)JSONDict andChildren:(BOOL)bParseChildren {
    if (!([JSONDict objectForKey:@"id"] &&
          [JSONDict objectForKey:@"state"] &&
          [JSONDict objectForKey:@"theme"] &&
          [JSONDict objectForKey:@"questions"] &&
          [JSONDict objectForKey:@"user_answers"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field in RoundParser");
        return nil;
    }
    
    Round* round = [[Round alloc] init];
    //id
    [round setID:[[JSONDict objectForKey:@"id"] unsignedLongLongValue]];
    //round state
    Round_State state = (Round_State)[[JSONDict objectForKey:@"state"] integerValue];
    [round setRound_state:state];
    
    if (bParseChildren) {
        //theme
        NSDictionary* themeDict = [JSONDict objectForKey:@"theme"];
        Theme* theme = [ThemeParser parse:themeDict];
        [round setTheme:theme];
        
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
            if ([ua relatedUserID] == [[Player instance] ID]) {
                [[round answersPlayer] addObject:ua];
            }
            else {
                [[round answersOpponent] addObject:ua];
            }
        }
    }
    return round;
}

@end
