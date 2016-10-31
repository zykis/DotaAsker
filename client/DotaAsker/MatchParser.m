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
    
    //state
    NSUInteger state = [[JSONDict objectForKey:@"state"] unsignedIntegerValue];
    [match setState:state];
    
    //users
    NSArray* usersDict = [JSONDict objectForKey:@"users"];
    for (NSDictionary* userDict in usersDict) {
        User* u = [UserParser parse:userDict andChildren:NO];
        [[match users] addObject:u];
    }

    if (bParseChildren) {
        if (!([JSONDict objectForKey:@"rounds"])) {
            NSLog(@"Parsing error: can't retrieve a field in MatchParser");
            return nil;
        }
        //rounds
        NSMutableArray* roundsDict = [JSONDict objectForKey:@"rounds"];
        for (NSDictionary* roundDict in roundsDict) {
            Round* r = [RoundParser parse:roundDict andChildren:YES];
            [[match rounds] addObject:r];
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
