//
//  Player.m
//  Real Estate Game
//
//  Created by Artem on 24/04/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "Player.h"
#import "UserAnswer.h"
#import <Realm/Realm.h>

@implementation Player

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
            user = [[User alloc] init];
        }
    }
    return user;
}

+ (void)setPlayer:(User *)player {
    [[self instance] setID:player.ID];
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
    
    //! Add locally stored unsynchronized UserAnswers if exists
    RLMResults<UserAnswer *> *userAnswers = [UserAnswer objectsWhere:@"synchronized == NO"];
    for (UserAnswer* ua in userAnswers) {
        //! Obtain round, that is equal to ua.realtedRound
        for (Match* m in [[self instance] matches])
        {
            BOOL found = NO;
            if (m.state == CURRENT_MATCH)
            {
                if (found)
                    break;
                for (Round* r in m.rounds)
                {
                    if ([r isEqual: ua.relatedRound])
                    {
                        [r.userAnswers addObject: ua];
                        found = YES;
                        break;
                    }
                }
            }
        }
    }
}

@end
