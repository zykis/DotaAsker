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
    if (self) {
        self.currentMatchesIDs = [[NSMutableArray alloc] init];
        self.recentMatchesIDs = [[NSMutableArray alloc] init];
        self.friendsIDs = [[NSMutableArray alloc] init];
    }
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

@end
