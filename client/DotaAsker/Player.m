//
//  Player.m
//  Real Estate Game
//
//  Created by Artem on 24/04/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "Player.h"
#import "UserAnswer.h"
#import "Match.h"
#import <Realm/Realm.h>

@implementation Player

static long long playerID = 0;

- (id)init {
    self = [super init];
    return self;
}

+ (User*)instance {
    User* user;
    if (playerID == 0) {
        NSException* exception = [NSException exceptionWithName:@"Player ID didn't set before calling [Player instance]"
                                                reason:@"Singleton implementation"
                                                userInfo:nil];
        @throw exception;
    }
    else {
        user = [User objectForPrimaryKey:@(playerID)];
    }
    return user;
}

+ (void)setID: (long long) ID {
    playerID = ID;
}

+ (void)manualUpdate: (User*)u /*unmanaged user object*/ {
    // Since a user, presented as Player will contain matches, that in it's turn
    // could contain user in [match users] with the same ID as Player, we should avoid updating entities
    // recursivly. Because we could clean up [Player matches], since [match users] are presented uncomplete (with empty
    // matches and friends properties)
    
    RLMRealm* realm = [RLMRealm defaultRealm];
    // [1] Remove all objects from Realm
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
    // [2] Update all variables, except matches, that will be updated manually
    User* uTmp = [[User alloc] init];
    [uTmp setMatches: u.matches];
    u.matches = nil;
    NSLog(@"root user matches count: %ld", [uTmp.matches count]);
    // [3] Iterating through matches, create or update all of it's properties except users.
    for(Match* m in uTmp.matches) {
        Match* mTmp = [[Match alloc] init];
        mTmp.ID = m.ID;
        mTmp.createdOn = m.createdOn;
        mTmp.updatedOn = m.updatedOn;
        mTmp.state = m.state;
        mTmp.mmrGain = m.mmrGain;
        mTmp.rounds = m.rounds;
        for(User* _u in m.users) {
            // [3.1] For each user inside [match users] check if user is root
            if (_u.ID == u.ID)
                // [3.1.1] If so set root user
                [mTmp.users addObject:u];
            else
                // [3.1.2] Else - add a new one
                [mTmp.users addObject:_u];
        }
        // [3.2] Update an existing match with a new one
        [u.matches addObject:mTmp];
    }
    // [4] Add modified user to Realm
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:u];
    [realm commitWriteTransaction];
    // update ID
    [Player setID:u.ID];
}

@end
