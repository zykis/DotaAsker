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

@end
