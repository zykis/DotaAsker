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
#import "UserService.h"
#import "RoundService.h"
#import "AnswerService.h"
#import "UserAnswerService.h"

@implementation MatchParser

- (Match*)parse:(NSDictionary *)JSONDict {
    if (!([JSONDict objectForKey:@"ID"] &&
          [JSONDict objectForKey:@"USERS_IDS"] &&
          [JSONDict objectForKey:@"STATE"] &&
          [JSONDict objectForKey:@"ROUNDS_IDS"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field in MatchParser");
        return nil;
    }
    
    Match* match = [[Match alloc] init];
    NSInteger scorePlayer = 0;
    NSInteger scoreOpponent = 0;
    
    //ID
    unsigned long long matchID = [[JSONDict objectForKey:@"ID"] unsignedLongLongValue];
    [match setID:matchID];
    //playerID
    NSArray* usersIDs = [JSONDict objectForKey:@"USERS_IDS"];
    for (int i = 0; i < [usersIDs count]; i++) {
        unsigned long long anID = [[usersIDs objectAtIndex:i] unsignedLongLongValue];
        if (anID == [[[UserService instance] player] ID]) {
            [match setPlayerID:anID];
        }
        else {
            [match setOpponentID:anID];
        }
    }
    //matchState
    MatchState state = (MatchState)[[JSONDict objectForKey:@"STATE"] integerValue];
    [match setState:state];

    //round IDs and score
    NSMutableArray* roundsIDs = [JSONDict objectForKey:@"ROUNDS_IDS"];
    [match setRoundsIDs:roundsIDs];
    for (int i = 0 ; i < [roundsIDs count]; i++) {
        unsigned long long rID = [[roundsIDs objectAtIndex:i] unsignedLongLongValue];
        Round* r = [[RoundService instance] obtain:rID];
        for (int j = 0; j < [r.answersPlayerIDs count]; j++) {
            unsigned long long uaID = [[r.answersPlayerIDs objectAtIndex:j] unsignedLongLongValue];
            UserAnswer* ua = [[UserAnswerService instance] obtain:uaID];
            if ([[UserAnswerService instance] isCorrect:ua]) {
                scorePlayer++;
            }
        }
        for (int j = 0; j < [r.answersOpponentIDs count]; j++) {
            unsigned long long uaID = [[r.answersOpponentIDs objectAtIndex:j] unsignedLongLongValue];
            UserAnswer* ua = [[UserAnswerService instance] obtain:uaID];
            if ([[UserAnswerService instance] isCorrect:ua]) {
                scoreOpponent++;
            }
        }
    }

    [match setScorePlayer: scorePlayer];
    [match setScoreOpponent:scoreOpponent];
    
    return match;
}

- (NSDictionary*)encode:(Match*)match {
    /*
     id = Column(Integer, primary_key=True)
     # (0 - not started, 1 - match running, 2 - match finished, 3 - time elapsed)
     state = Column(Integer, nullable=True, default=0)
     initiator_id = Column(Integer, ForeignKey('users.id'), nullable=False)
     next_move_user_id = Column(Integer, ForeignKey('users.id'), nullable=True)
     winner_id = Column(Integer, ForeignKey('users.id'), default=0)
     # relations
     users = relationship('User', secondary='users_matches')
     rounds = relationship('Round')
     initiator = relationship('User', foreign_keys=[next_move_user_id])
     next_move_user = relationship('User', foreign_keys=[next_move_user_id])
     winner = relationship('User', foreign_keys=[winner_id])
     */
    NSArray* users = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedLongLong:match.playerID],
                      [NSNumber numberWithUnsignedLongLong:match.opponentID],
                      nil];
    NSDictionary* jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedLongLong: match.ID], @"ID",
                              [NSNumber numberWithInt: (int)match.state], @"STATE",
                              users, @"USERS_IDS",
                              match.roundsIDs, @"ROUNDS_IDS",
                              nil];
    return jsonDict;
}

@end
