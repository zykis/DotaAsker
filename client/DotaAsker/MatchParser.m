//
//  MatchParser.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "MatchParser.h"
#import "RoundParser.h"
#import "UserParser.h"
#import "Match.h"
#import "Round.h"
#import "User.h"

@implementation MatchParser

- (Match*)parse:(NSDictionary *)JSONDict {
    if (!([JSONDict objectForKey:@"ID"] &&
          [JSONDict objectForKey:@"WINNER_ID"] &&
          [JSONDict objectForKey:@"PLAYER_ID"] &&
          [JSONDict objectForKey:@"OPPONENT_ID"] &&
          [JSONDict objectForKey:@"STATE"] &&
          [JSONDict objectForKey:@"SCORE_PLAYER"] &&
          [JSONDict objectForKey:@"SCORE_OPPONENT"] &&
          [JSONDict objectForKey:@"ROUNDS_IDS"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field");
        return nil;
    }
    
    Match* match = [[Match alloc] init];
    //ID
    unsigned long long matchID = [[JSONDict objectForKey:@"ID"] unsignedLongLongValue];
    [match setID:matchID];
    //winnerID
    unsigned long long winnerID = [[JSONDict objectForKey:@"WINNER_ID"] unsignedLongLongValue];
    [match setWinnerID:winnerID];
    //playerID
    unsigned long long playerID = [[JSONDict objectForKey:@"PLAYER_ID"] unsignedLongLongValue];
    [match setPlayerID:playerID];
    //opponentID
    unsigned long long opponentID = [[JSONDict objectForKey:@"OPPONENT_ID"] unsignedLongLongValue];
    [match setOpponentID:opponentID];
    //matchState
    MatchState state = (MatchState)[[JSONDict objectForKey:@"STATE"] integerValue];
    [match setState:state];
    //scorePlayer
    NSInteger scorePlayer = [[JSONDict objectForKey:@"SCORE_PLAYER"] integerValue];
    [match setScorePlayer: scorePlayer];
    //scoreOpponent
    NSInteger scoreOpponent = [[JSONDict objectForKey:@"SCORE_OPPONENT"] integerValue];
    [match setScoreOpponent: scoreOpponent];
    //round IDs
    NSMutableArray* roundsIDs = [JSONDict objectForKey:@"ROUNDS_IDS"];
    [match setRoundsIDs:roundsIDs];
    
    return match;
}

@end
