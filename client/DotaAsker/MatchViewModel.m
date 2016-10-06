//
//  MatchViewModel.m
//  DotaAsker
//
//  Created by Artem on 01/10/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "MatchViewModel.h"
#import "Player.h"
#import "UserAnswer.h"
#import "Answer.h"
#import "Round.h"
#import "Question.h"
#import "Match.h"

@implementation MatchViewModel

@synthesize match = _match;

- (NSString*)playerImagePath {
    return [[Player instance] avatarImageName];
}

- (NSString*)playerName {
    return [[Player instance] name];
}

- (NSString*)opponentImagePath {
    for (User* u in [_match users]) {
        if (![u isEqual: (User*)[Player instance]])
            return [u avatarImageName];
    }
    if([_match state] == MATCH_NOT_STARTED)
        return @"avatar_default.png";
    else
        assert(0);
}

- (NSString*)opponentName {
    for (User* u in [_match users]) {
        if (![u isEqual: (User*)[Player instance]])
            return [u name];
    }
    if([_match state] == MATCH_NOT_STARTED)
        return @"Player";
    else
        assert(0);
}

- (NSUInteger)playerScore {
    NSUInteger opponentScore = 0;
    NSUInteger playerScore = 0;
    for (Round* r in [_match rounds]) {
        for (UserAnswer* ua in [r userAnswers]) {
            if ([[ua relatedAnswer] isCorrect])
            {
                if([[ua relatedUser] isEqual:[Player instance]])
                    playerScore++;
                else
                    opponentScore++;
            }
        }
    }
    [_match setScorePlayer:playerScore];
    [_match setScoreOpponent:opponentScore];
    return [_match scorePlayer];
}

- (NSUInteger)opponentScore {
    NSUInteger opponentScore = 0;
    NSUInteger playerScore = 0;
    for (Round* r in [_match rounds]) {
        for (UserAnswer* ua in [r userAnswers]) {
            if ([[ua relatedAnswer] isCorrect])
            {
                if([[ua relatedUser] isEqual:[Player instance]])
                    playerScore++;
                else
                    opponentScore++;
                    }
        }
    }
    [_match setScorePlayer:playerScore];
    [_match setScoreOpponent:opponentScore];
    return [_match scoreOpponent];
}

- (NSUInteger)answerStateforRoundInRow:(NSUInteger)row andAnswerIndex:(NSUInteger)index forPlayer:(BOOL)bPlayer {
    // index [0..2]
    Round* r = [[_match rounds] objectAtIndex:row];
    NSMutableArray* playerAnswers = [[NSMutableArray alloc] init];
    NSMutableArray* opponentAnswers = [[NSMutableArray alloc] init];
    for (UserAnswer* ua in [r userAnswers]) {
        if ([[ua relatedUser] isEqual:[Player instance]]) {
            [playerAnswers addObject:ua];
        }
        else {
            [opponentAnswers addObject:ua];
        }
    }
    if (bPlayer) {
        return [[[playerAnswers objectAtIndex:index] relatedAnswer] isCorrect];
    }
    else {
        return [[[opponentAnswers objectAtIndex:index] relatedAnswer] isCorrect];
    }
}

- (Round_State)roundStateForRoundInRow:(NSUInteger)row {
    Round_State rs = [[[_match rounds] objectAtIndex:row] round_state];
    
    if(rs == 3) { // ROUND_ANSWERING
        if([_match nextMoveUserID] == [[Player instance] ID])
            rs = ROUND_PLAYER_ASWERING;
        else
            rs = ROUND_OPPONENT_ANSWERING;
    }
    else if(rs == 4) {
        if([_match nextMoveUserID] == [[Player instance] ID])
            rs = ROUND_PLAYER_REPLYING;
        else
            rs = ROUND_OPPONENT_REPLYING;
    }
    return rs;
}

- (Round_State)roundStateForCurrentRound {
    Round* currentRound;
    NSUInteger index = 0;
    for (Round* r in [_match rounds]) {
        if (([r round_state] != ROUND_FINISHED) && ([r round_state] != ROUND_TIME_ELAPSED)
            && ([r round_state] != ROUND_NOT_STARTED))
            index++;
    }
    currentRound = [[_match rounds] objectAtIndex:index];
    
    Round_State rs = [currentRound round_state];
    
    if(rs == 3) { // ROUND_ANSWERING
        if([_match nextMoveUserID] == [[Player instance] ID])
            rs = ROUND_PLAYER_ASWERING;
        else
            rs = ROUND_OPPONENT_ANSWERING;
    }
    else if(rs == 4) {
        if([_match nextMoveUserID] == [[Player instance] ID])
            rs = ROUND_PLAYER_REPLYING;
        else
            rs = ROUND_OPPONENT_REPLYING;
    }
    
    return rs;
}

- (MatchState)matchState {
    return [_match state];
}

- (NSUInteger)playerAnswersCountForRoundInRow:(NSUInteger)row {
    Round* r = [[_match rounds] objectAtIndex:row];
    NSUInteger playerAnswersCount = 0;
    for (UserAnswer *ua in [r userAnswers]) {
        if ([ua relatedUser] == (User*)[Player instance])
            playerAnswersCount++;
    }
    return playerAnswersCount;
}

- (NSString*)textForUserAnswerForRoundInRow:(NSUInteger)row andUserAnswerIndex:(NSUInteger)index {
    /* index = [0..2] */
    NSString* text;
    Round* selectedRound = [[_match rounds] objectAtIndex:row];
    switch ([selectedRound round_state]) {
        case ROUND_FINISHED: {
            User* player = [Player instance];
            User* opponent;
            for (User* u in [_match users]) {
                if(![u isEqual: player])
                    opponent = u;
            }
            
            NSMutableArray *playerAnswers = [[NSMutableArray alloc] init];
            for (UserAnswer *ua in [selectedRound userAnswers]) {
                if ([[ua relatedUser] isEqual: player]) {
                    [playerAnswers addObject:ua];
                }
            }
            UserAnswer* ua1 = [playerAnswers objectAtIndex:index];
            NSString *answeredTextFirstPlayer = [[ua1 relatedAnswer] text];
            
            NSMutableArray *opponentAnswers = [[NSMutableArray alloc] init];
            for (UserAnswer *ua in [selectedRound userAnswers]) {
                if ([[ua relatedUser] isEqual: opponent]) {
                    [opponentAnswers addObject:ua];
                }
            }
            UserAnswer* ua2 = [opponentAnswers objectAtIndex:index];
            NSString *answeredTextSecondPlayer = [[ua2 relatedAnswer] text];
            
            NSString* correctAnswerText;
            for (Answer* a in [[ua1 relatedQuestion] answers]) {
                if ([a isCorrect]) {
                    correctAnswerText = [a text];
                }
            }
            
            if (correctAnswerText) {
                text = [NSString stringWithFormat:
                        @"%@\n\n"
                        "%@: %@\n"
                        "%@: %@\n"
                        "Right: %@"
                        , ua1.relatedQuestion.text,
                        [player name],
                        answeredTextFirstPlayer,
                        [opponent name],
                        answeredTextSecondPlayer,
                        correctAnswerText
                        ];
            }
        }
            break;
        case ROUND_OPPONENT_REPLYING: {
            User* player = (User*)[Player instance];
            NSMutableArray *playerAnswers = [[NSMutableArray alloc] init];
            for (UserAnswer *ua in [selectedRound userAnswers]) {
                if ([ua relatedUser] == player) {
                    [playerAnswers addObject:ua];
                }
            }
            UserAnswer* ua1 = [playerAnswers objectAtIndex:index];
            NSString *answeredTextFirstPlayer = [[ua1 relatedAnswer] text];
            
            NSString* correctAnswerText;
            for (Answer* a in [[ua1 relatedQuestion] answers]) {
                if ([a isCorrect]) {
                    correctAnswerText = [a text];
                }
            }
            
            if (correctAnswerText) {
                text = [NSString stringWithFormat:
                        @"%@\n\n"
                        "%@: %@\n"
                        "Right: %@"
                        , ua1.relatedQuestion.text,
                        [player name],
                        answeredTextFirstPlayer,
                        correctAnswerText
                        ];
            }
        }
        break;
            
        case ROUND_PLAYER_REPLYING: {
            text = [NSString stringWithFormat:@"Hidden"];
        }
        break;
            
        default:
            text = nil;
    }
    return text;
}

@end
