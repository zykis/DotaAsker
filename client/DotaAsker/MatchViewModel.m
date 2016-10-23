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
#import "ServiceLayer.h"

@implementation MatchViewModel

@synthesize match = _match;

- (User*)opponent {
    for (User* u in [_match users]) {
        if (![u isEqual: [Player instance]])
            return u;
    }
    return nil;
}

- (User*)nextMoveUser {
    User* nextMoveUser = [[[[ServiceLayer instance] roundService] currentRoundforMatch:_match] nextMoveUser];
    return nextMoveUser;
}

- (NSUInteger)answerStateforRoundInRow:(NSUInteger)row andAnswerIndex:(NSUInteger)index {
    // index [0..5]
    // 0 -answerIncorrect, 1 - answerCorrect, 2 - answerHidden
    Round* r = [[_match rounds] objectAtIndex:row];
    return [[[r userAnswers] objectAtIndex:index] isCorrect];
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
    NSString* text;
    Round* selectedRound = [[_match rounds] objectAtIndex:row];
    User* player = [Player instance];
    User* opponent = [self opponent];
    
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
    for (Answer* a in [[[ua1 relatedAnswer] relatedQuestion] answers]) {
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
                , ua1.relatedAnswer.relatedQuestion.text,
                [player name],
                answeredTextFirstPlayer,
                [opponent name],
                answeredTextSecondPlayer,
                correctAnswerText
                ];
    }
    return text;
}

- (NSUInteger)playerScore {
    NSUInteger score = [[[ServiceLayer instance] matchService] scoreForMatch:_match andUser:[Player instance]];
    return score;
}

- (NSUInteger)opponentScore {
    NSUInteger score = [[[ServiceLayer instance] matchService] scoreForMatch:_match andUser:[self opponent]];
    return score;
}

@end
