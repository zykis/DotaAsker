//
//  MainViewModel.m
//  DotaAsker
//
//  Created by Artem on 27/09/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "MainViewModel.h"
#import "Player.h"
#import "Match.h"
#import "User.h"
#import "Round.h"

@implementation MainViewModel

- (NSUInteger)currentMatchesCount {
    return [[[Player instance] currentMatches] count];
}

- (NSUInteger)recentMatchesCount {
    return [[[Player instance] recentMatches] count];
}

- (NSString*)playerImagePath {
    return [[Player instance] avatarImageName];
}

- (NSString*)opponentImagePathForCurrentMatch:(NSUInteger)row {
    Match* m = [[[Player instance] currentMatches] objectAtIndex:row];
    for (User* u in m.users) {
        if (![u isEqual: [Player instance]]) {
            return [u avatarImageName];
        }
    }
    if([m state] == MATCH_NOT_STARTED)
        return @"avatar_default.png";
    NSLog(@"No avatar found for user in MainViewModel");
    return nil;
}

- (NSString*)opponentImagePathForRecentMatch:(NSUInteger)row {
    Match* m = [[[Player instance] recentMatches] objectAtIndex:row];
    for (User* u in m.users) {
        if (![u isEqual: [Player instance]]) {
            return [u avatarImageName];
        }
    }
    if([m state] == MATCH_NOT_STARTED)
        return @"avatar_default.png";
    NSLog(@"No avatar found for user in MainViewModel");
    return nil;
}

- (NSString*)playerName {
    return [[Player instance] name];
}

- (NSUInteger)playerKDA {
    return [[Player instance] KDA];
}

- (NSUInteger)playerGPM {
    return [[Player instance] GPM];
}

- (NSUInteger)playerMMR {
    return [[Player instance] MMR];
}

- (NSString*)matchStateTextForCurrentMatch:(NSUInteger)row {
    Match* m = [[[Player instance] currentMatches] objectAtIndex:row];
    switch ([m state]) {
        case MATCH_NOT_STARTED:
            return @"Not started";
        case MATCH_RUNNING:
            return @"Running";
        case MATCH_FINISHED:
            return @"Finished";
        case MATCH_TIME_ELAPSED:
            return @"Time elapsed";
        default:
            NSLog(@"Undefined match state in MainViewModel");
            return nil;
    }
}

- (NSString*)matchStateTextForRecentMatch:(NSUInteger)row {
    Match* m = [[[Player instance] recentMatches] objectAtIndex:row];
    switch ([m state]) {
        case MATCH_NOT_STARTED:
            return @"Not started";
        case MATCH_RUNNING:
            return @"Running";
        case MATCH_FINISHED:
            return @"Finished";
        case MATCH_TIME_ELAPSED:
            return @"Time elapsed";
        default:
            NSLog(@"Undefined match state in MainViewModel");
            return nil;
    }
}

- (NSString*)opponentNameForCurrentMatch:(NSUInteger)row {
    Match* m = [[[Player instance] currentMatches] objectAtIndex:row];
    for (User* u in m.users) {
        if (![u isEqual: [Player instance]]) {
            return [u name];
        }
    }
    if([m state] == MATCH_NOT_STARTED)
        return @"Player";
    NSLog(@"Undefined name for user in MainViewModel");
    return nil;
}

- (NSString*)opponentNameForRecentMatch:(NSUInteger)row {
    Match* m = [[[Player instance] recentMatches] objectAtIndex:row];
    for (User* u in m.users) {
        if (![u isEqual: [Player instance]]) {
            return [u name];
        }
    }
    if([m state] == MATCH_NOT_STARTED)
        return @"Player";
    NSLog(@"Undefined name for user in MainViewModel");
    return nil;
}

- (Match*)currentMatchAtRow: (NSUInteger)row {
    Match* m = [[[Player instance] currentMatches] objectAtIndex:row];
    return m;
}
- (Match*)recentMatchAtRow: (NSUInteger)row {
    Match* m = [[[Player instance] recentMatches] objectAtIndex:row];
    return m;
}
@end
