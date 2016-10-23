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

- (NSUInteger)currentMatchesCount {
    return [[[Player instance] currentMatches] count];
}

- (NSUInteger)recentMatchesCount {
    return [[[Player instance] recentMatches] count];
}

- (NSString*)matchStateTextForCurrentMatch:(NSUInteger)row {
    Match* m = [[[Player instance] currentMatches] objectAtIndex:row];
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
    Match* m = [[[Player instance] recentMatches] objectAtIndex:row];
    Round* currentRound = [[[ServiceLayer instance] roundService] currentRoundforMatch:m];
    if ([currentRound isEqual:[[m rounds] lastObject]])
        return @"Finished";
    else
        return @"Time Elapsed";
}

- (User*)opponentForCurrentMatch:(NSUInteger)row {
    Match* m = [[[Player instance] currentMatches] objectAtIndex:row];
    for (User* u in m.users) {
        if (![u isEqual: [Player instance]]) {
            return u;
        }
    }
    User* op = [[User alloc] init];
    return op;
}

- (User*)opponentForRecentMatch:(NSUInteger)row {
    Match* m = [[[Player instance] recentMatches] objectAtIndex:row];
    for (User* u in m.users) {
        if (![u isEqual: [Player instance]]) {
            return u;
        }
    }
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
