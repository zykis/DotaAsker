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
    static User *user = nil;
    @synchronized(self)
    {
        if(user == nil)
        {
            if (playerID == 0) {
                NSException* exception = [NSException exceptionWithName:@"Player ID didn't set before calling [Player instance]"
                                                        reason:@"Singleton implementation"
                                                        userInfo:nil];
                @throw exception;
            }
            else {
                user = [User objectWithPrimaryKey:@playerID];
                // If not user in local database, create one
                if (user == nil) {
                    user = [[User alloc] init];
                }
            }
        }
    }
    return user;
}

+ (void)setPlayer:(User *)player {
    if (![[self instance] ID])
        [[self instance] setID:player.ID];
    
    // Updating user instance in lcoal DB
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    
    [[self instance] setName:player.name];
    [[self instance] setEmail:player.email];
    [[self instance] setMMR:player.MMR];
    [[self instance] setKDA:player.KDA];
    [[self instance] setGPM:player.GPM];
    [[self instance] setWallpapersImageName:player.wallpapersImageName];
    [[self instance] setAvatarImageName:player.avatarImageName];
    [[self instance] setTotalCorrectAnswers:player.totalCorrectAnswers];
    [[self instance] setTotalIncorrectAnswers:player.totalIncorrectAnswers];
    [[self instance] setRole:player.role];
    [[self instance] setMatches:player.matches];
    [[self instance] setFriends:player.friends];
    
    [realm commitWriteTransaction];
}

+ (void)setID: long long ID {
    playerID = ID;
}

@end
