//
//  Player.m
//  Real Estate Game
//
//  Created by Artem on 24/04/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "Player.h"

@implementation Player

- (id)init {
    self = [super init];
    return self;
}

+ (Player*)instance {
    static Player *player = nil;
    @synchronized(self)
    {
        if(player == nil)
        {
            player = [[self alloc] init];
        }
    }
    return player;
}

- (void)setPlayer:(User *)player {
    [self setID:player.ID];
    [self setName:player.name];
    [self setEmail:player.email];
    [self setMMR:player.MMR];
    [self setKDA:player.KDA];
    [self setGPM:player.GPM];
    [self setWallpapersImageName:player.wallpapersImageName];
    [self setAvatarImageName:player.avatarImageName];
    [self setTotalCorrectAnswers:player.totalCorrectAnswers];
    [self setTotalIncorrectAnswers:player.totalIncorrectAnswers];
    [self setRole:player.role];
    [self setCurrentMatches:player.currentMatches];
    [self setRecentMatches:player.recentMatches];
    [self setFriends:player.friends];
}

@end
