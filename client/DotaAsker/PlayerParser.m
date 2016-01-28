//
//  PlayerParser.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "PlayerParser.h"
#import "UserParser.h"
#import "MatchParser.h"
#import "MatchService.h"
#import "Player.h"
#import "Match.h"

@implementation PlayerParser

- (Player*)parse:(NSDictionary *)JSONDict {
    if (![JSONDict isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Trying to pass not a dictionary to parse method.");
        return nil;
//        @throw [NSException exceptionWithName:@"Trying to pass not a dictionary to parse method." reason:nil userInfo:nil];
    }
    if (!([JSONDict objectForKey:@"MATCHES"]
//          [JSONDict objectForKey:@"FRIENDS_IDS"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field in PlayerParser");
        return nil;
    }
    
    UserParser *userParser = [[UserParser alloc] init];
    Player* player = (Player*)[userParser parse:JSONDict];
    
    
//    [player setCurrentMatchesIDs: [JSONDict objectForKey:@"CURRENT_MATCHES_IDS"]];
//    [player setRecentMatchesIDs: [JSONDict objectForKey:@"RECENT_MATCHES_IDS"]];
//    [player setFriendsIDs: [JSONDict objectForKey:@"FRIENDS_IDS"]];
    return player;
}

@end
