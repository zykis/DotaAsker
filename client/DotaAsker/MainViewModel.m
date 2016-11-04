//
//  MainViewModel.m
//  DotaAsker
//
//  Created by Artem on 27/09/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "MainViewModel.h"
#import "Player.h"
#import "ServiceLayer.h"
#import "Match.h"
#import "User.h"
#import "Round.h"

@implementation MainViewModel

- (NSUInteger)matchSectionForMatch:(Match *)match {
    if ([match state] != MATCH_RUNNING)
        return RECENT_MATCH;
    else {
        Round* currentRound = [[[ServiceLayer instance] roundService] currentRoundforMatch:match];
        if ([[currentRound nextMoveUser] isEqual:[Player instance]]) {
            return CURRENT_MATCH;
        }
        else
            return WAITING_MATCH;
    }
    assert(0);
}

- (NSMutableArray*)currentMatches {
    NSMutableArray* currentMatches = [[NSMutableArray alloc] init];
    for (Match* m in [[Player instance] matches]) {
        if ([self matchSectionForMatch:m] == CURRENT_MATCH)
            [currentMatches addObject:m];
    }
    return currentMatches;
}

- (NSMutableArray*)waitingMatches {
    NSMutableArray* waitingMatches = [[NSMutableArray alloc] init];
    for (Match* m in [[Player instance] matches]) {
        if ([self matchSectionForMatch:m] == WAITING_MATCH)
            [waitingMatches addObject:m];
    }
    return waitingMatches;
}

- (NSMutableArray*)recentMatches {
    NSMutableArray* recentMatches = [[NSMutableArray alloc] init];
    for (Match* m in [[Player instance] matches]) {
        if ([self matchSectionForMatch:m] == RECENT_MATCH)
            [recentMatches addObject:m];
    }
    return recentMatches;
}

- (NSUInteger)currentMatchesCount {
    return [[self currentMatches] count];
}

- (NSUInteger)waitingMatchesCount {
    return [[self waitingMatches] count];
}

- (NSUInteger)recentMatchesCount {
    return [[self recentMatches] count];
}

- (NSString*)matchStateTextForCurrentMatch:(NSUInteger)row {
    Match* m = [[self currentMatches] objectAtIndex:row];
    // If less, then 2 users, then you created match and you are - initiator
    if ([m.users count] < 2)
        return @"You answering";
    else {
        Round* currentRound = [[[ServiceLayer instance] roundService] currentRoundforMatch:m];
        if ([[currentRound nextMoveUser] isEqual:[Player instance]]) {
            BOOL thereIsOpponentAnswer = NO;
            for (UserAnswer* ua in [currentRound userAnswers]) {
                if (![[ua relatedUser] isEqual:[Player instance]]) {
                    thereIsOpponentAnswer = YES;
                    break;
                }
            }
            if (thereIsOpponentAnswer) {
                return @"You replying";
            }
            else {
                return @"You answering";
            }
        }
        else {
            BOOL thereIsPlayerAnswer = NO;
            for (UserAnswer* ua in [currentRound userAnswers]) {
                if ([[ua relatedUser] isEqual:[Player instance]]) {
                    thereIsPlayerAnswer = YES;
                    break;
                }
            }
            if (thereIsPlayerAnswer) {
                return @"Opponent replying";
            }
            else {
                return @"Opponent answering";
            }
        }
    }
}

- (NSString*)matchStateTextForRecentMatch:(NSUInteger)row {
    Match* m = [[self recentMatches] objectAtIndex:row];
    if ([m state] == MATCH_FINISHED)
        return @"Finished";
    else if ([m state] == MATCH_TIME_ELAPSED)
        return @"Time elapsed";
    else
        assert(0);
}

- (NSString*)matchStateTextForWaitingMatch:(NSUInteger)row {
    return @"Waiting";
}

- (User*)opponentForCurrentMatch:(NSUInteger)row {
    Match* m = [[self currentMatches] objectAtIndex:row];
    for (User* u in m.users) {
        if (![u isEqual: [Player instance]]) {
            return u;
        }
    }
    User* op = [[User alloc] init];
    return op;
}

- (User*)opponentForWaitingMatch:(NSUInteger)row {
    Match* m = [[self waitingMatches] objectAtIndex:row];
    for (User* u in m.users) {
        if (![u isEqual: [Player instance]]) {
            return u;
        }
    }
    User* op = [[User alloc] init];
    return op;
}

- (User*)opponentForRecentMatch:(NSUInteger)row {
    Match* m = [[self recentMatches] objectAtIndex:row];
    for (User* u in m.users) {
        if (![u isEqual: [Player instance]]) {
            return u;
        }
    }
    return nil;
}

- (Match*)currentMatchAtRow: (NSUInteger)row {
    Match* m = [[self currentMatches] objectAtIndex:row];
    return m;
}

- (Match*)waitingMatchAtRow:(NSUInteger)row {
    Match* m = [[self waitingMatches] objectAtIndex:row];
    return m;
}

- (Match*)recentMatchAtRow: (NSUInteger)row {
    Match* m = [[self recentMatches] objectAtIndex:row];
    return m;
}
@end
