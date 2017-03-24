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

- (NSArray*)currentMatches {
    NSMutableArray* resultMatches = [[NSMutableArray alloc] init];
    
    for (Match* m in [Match allObjects]) {
        if ([self matchSectionForMatch:m] == CURRENT_MATCH)
            [resultMatches addObject:m];
    }
    
    // Sorting array by updated date
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedOn" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    NSArray *sortedMatches = [resultMatches sortedArrayUsingDescriptors:sortDescriptors];
    
    return [NSArray arrayWithArray: sortedMatches];
}

- (NSArray*)waitingMatches {
    NSMutableArray* resultMatches = [[NSMutableArray alloc] init];
    
    for (Match* m in [Match allObjects]) {
        if ([self matchSectionForMatch:m] == WAITING_MATCH)
            [resultMatches addObject:m];
    }
    
    // Sorting array by updated date
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedOn" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    NSArray *sortedMatches = [resultMatches sortedArrayUsingDescriptors:sortDescriptors];
    
    return [NSArray arrayWithArray: sortedMatches];
}

- (NSArray*)recentMatches {
    NSMutableArray* resultMatches = [[NSMutableArray alloc] init];
    
    for (Match* m in [Match allObjects]) {
        if ([self matchSectionForMatch:m] == RECENT_MATCH)
            [resultMatches addObject:m];
    }
    
    // Sorting array by updated date
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedOn" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    NSArray *sortedMatches = [resultMatches sortedArrayUsingDescriptors:sortDescriptors];
    
    return [NSArray arrayWithArray: sortedMatches];
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
            // What if there are no opponent answers due to poor connection?
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

- (User*)opponentForMatch:(Match *)match {
    for (User* u in [match users]) {
        if (![u isEqual: [Player instance]])
            return u;
    }
    User* defaultUser = [[User alloc] init];
    return defaultUser;
}

- (NSString*)matchStateTextForRecentMatch:(NSUInteger)row {
    Match* m = [[self recentMatches] objectAtIndex:row];
    if ([m state] == MATCH_FINISHED) {
        User* winner = m.winner;
        switch(m.finishReason) {
            case MATCH_FINISH_REASON_NORMAL:
            {
                if (winner == nil) {
                    NSUInteger playerScore = [[[ServiceLayer instance] matchService] scoreForMatch:m andUser:[Player instance]];
                    NSUInteger opponentScore = [[[ServiceLayer instance] matchService] scoreForMatch:m andUser:opponent];
                    assert(playerScore == opponentScore);
                    return @"Draw";
                }
                else if ([winner isEqual:opponent]) {
                    return @"You lost!";
                }
                else if ([winner isEqual:[Player instance]]) {
                    return @"You won!";
                }
                else {
                    assert(0);
                }
            }
            break;
            
            case MATCH_FINISH_REASON_TIME_ELAPSED:
            {
                if ([winner isEqual:opponent]) {
                    return @"You lost! (time elapsed)";
                }
                else if ([winner isEqual:[Player instance]]) {
                    return @"You won! (time elapsed)";
                }
                else {
                    assert(0);
                } 
            }
            break;
            
            case MATCH_FINISH_REASON_SURREND:
            {
                if ([winner isEqual:opponent]) {
                    return @"You surrended";
                }
                else if ([winner isEqual:[Player instance]]) {
                    return @"Opponent surrended";
                }
                else {
                    assert(0);
                }
            }
            break;
            
            default: assert(0);
        }
    }
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
