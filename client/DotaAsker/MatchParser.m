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
//#import "Player.h"
#import "UserAnswer.h"

@implementation MatchParser

+ (Match*)parse:(NSDictionary *)JSONDict andChildren:(BOOL)bParseChildren {
    if (!([JSONDict objectForKey:@"id"] &&
          [JSONDict objectForKey:@"users"] &&
          [JSONDict objectForKey:@"state"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field in MatchParser");
        return nil;
    }
    
    Match* match = [[Match alloc] init];
    
    //ID
    unsigned long long matchID = [[JSONDict objectForKey:@"id"] unsignedLongLongValue];
    [match setID:matchID];
    
    //Next Move user ID
    NSUInteger nextMoveUserID = [[JSONDict objectForKey:@"next_move_user"] unsignedLongLongValue];
    [match setNextMoveUserID:nextMoveUserID];
    
    //users
    NSArray* usersDict = [JSONDict objectForKey:@"users"];
    for (NSDictionary* userDict in usersDict) {
        User* u = [UserParser parse:userDict andChildren:NO];
        [[match users] addObject:u];
    }
    //matchState
    MatchState state = (MatchState)[[JSONDict objectForKey:@"state"] integerValue];
    [match setState:state];

    if (bParseChildren) {
        if (!([JSONDict objectForKey:@"rounds"])) {
            NSLog(@"Parsing error: can't retrieve a field in MatchParser");
            return nil;
        }
        //rounds
        NSMutableArray* roundsDict = [JSONDict objectForKey:@"rounds"];
        NSUInteger playerScore = 0;
        NSUInteger opponentScore = 0;
        for (NSDictionary* roundDict in roundsDict) {
            Round* r = [RoundParser parse:roundDict andChildren:YES];
            for (User* u in [match users]) {
                for (UserAnswer* ua in [r userAnswers]) {
                    if (ua.relatedUserID == u.ID) {
                        [ua setRelatedUser:u];
                    }
                }
            }
            [[match rounds] addObject:r];
            
            //! TODO: score
            [match setScorePlayer:playerScore];
            [match setScoreOpponent:opponentScore];
        }
    }
    
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
//    NSArray* users = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedLongLong:match.playerID],
//                      [NSNumber numberWithUnsignedLongLong:match.opponentID],
//                      nil];
//    NSDictionary* jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
//                              [NSNumber numberWithUnsignedLongLong: match.ID], @"ID",
//                              [NSNumber numberWithInt: (int)match.state], @"STATE",
//                              users, @"USERS",
//                              match.rounds, @"ROUNDS",
//                              nil];
//    return jsonDict;
    return [[NSDictionary alloc] init];
}

@end
