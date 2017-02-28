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
#import "RoundService.h"
#import <Realm/Realm.h>

@implementation MatchViewModel

@synthesize matchID = _matchID;

- (Match*)match {
    return [Match objectForPrimaryKey:@(_matchID)];
}

- (User*)opponent {
    for (User* u in [[self match] users]) {
        if (![u isEqual: [Player instance]])
            return u;
    }
    User* defaultUser = [[User alloc] init];
    return defaultUser;
}

- (User*)nextMoveUser {
    User* nextMoveUser = [[[[ServiceLayer instance] roundService] currentRoundforMatch:[self match]] nextMoveUser];
    return nextMoveUser;
}

- (NSString*)roundStatusTextForRoundInRow:(NSUInteger)row {
    Round *r = [[[self match] rounds] objectAtIndex:row];
    Theme* theme = [[[ServiceLayer instance] roundService] themeSelectedForRound:r];
    NSString* str;
    if (theme)
        str = [NSString stringWithFormat:@"%@", [theme name]];
    return str;
}

- (NSUInteger)answerStateforRoundInRow:(NSUInteger)row andAnswerIndex:(NSUInteger)index {
    // index [0..5]
    // 0 -answerIncorrect, 1 - answerCorrect, 2 - answerHidden
    Round* r = [[[self match] rounds] objectAtIndex:row];
    return [[[[r userAnswers] objectAtIndex:index] relatedAnswer] isCorrect];
}

- (NSUInteger)playerAnswersCountForRoundInRow:(NSUInteger)row {
    Round* r = [[[self match] rounds] objectAtIndex:row];
    NSUInteger playerAnswersCount = 0;
    for (UserAnswer *ua in [r userAnswers]) {
        if ([[ua relatedUser] isEqual: [Player instance]])
            playerAnswersCount++;
    }
    return playerAnswersCount;
}

- (NSString*)textForUserAnswerForRoundInRow:(NSUInteger)row andUserAnswerIndex:(NSUInteger)index {
    NSString* text;
    Round* selectedRound = [[[self match] rounds] objectAtIndex:row];
    User* player = [Player instance];
    User* opponent = [self opponent];
    
    
    NSMutableArray *playerAnswers = [[NSMutableArray alloc] init];
    for (UserAnswer *ua in [selectedRound userAnswers]) {
        if ([[ua relatedUser] isEqual: player]) {
            [playerAnswers addObject:ua];
        }
    }
    
    NSString *answeredTextFirstPlayer;
    if ([playerAnswers count] > index) {
        UserAnswer* ua1 = [playerAnswers objectAtIndex:index];
        answeredTextFirstPlayer = [[ua1 relatedAnswer] text];
    }
    
    // opponent
    NSMutableArray *opponentAnswers = [[NSMutableArray alloc] init];
    for (UserAnswer *ua in [selectedRound userAnswers]) {
        if ([[ua relatedUser] isEqual: opponent]) {
            [opponentAnswers addObject:ua];
        }
    }
    
    NSString *answeredTextSecondPlayer;
    if ([opponentAnswers count] > index) {
        UserAnswer* ua2 = [opponentAnswers objectAtIndex:index];
        answeredTextSecondPlayer = [[ua2 relatedAnswer] text];
    }
    
    // right
    // How to get THEME?
    Theme* selectedTheme = [[[ServiceLayer instance] roundService] themeSelectedForRound:selectedRound];
    assert(selectedTheme);
    Question* relatedQuestion = [[[ServiceLayer instance] roundService] questionAtIndex:index onTheme:selectedTheme inRound:selectedRound];
    assert(relatedQuestion);
    
    NSString* correctAnswerText;
    for (Answer* a in [relatedQuestion answers]) {
        if ([a isCorrect]) {
            correctAnswerText = [a text];
        }
    }
    
    // 3 cases:
    // [1] Player answered, opponent - not
    // [2] Player answered, opponent - too
    // [3] Player didn't answer, opponent - answered
    
    if (correctAnswerText) {
        if ((answeredTextFirstPlayer) && (answeredTextSecondPlayer))
            text = [NSString stringWithFormat:
                    @"%@\n\n"
                    "%@: %@\n"
                    "%@: %@\n"
                    "Right: %@"
                    , relatedQuestion.text,
                    [player name],
                    answeredTextFirstPlayer,
                    [opponent name],
                    answeredTextSecondPlayer,
                    correctAnswerText
                    ];
        else if ((answeredTextFirstPlayer) && (!answeredTextSecondPlayer))
            text = [NSString stringWithFormat:
                    @"%@\n\n"
                    "%@: %@\n"
                    "Right: %@"
                    , relatedQuestion.text,
                    [player name],
                    answeredTextFirstPlayer,
                    correctAnswerText
                    ];
        else if ((!answeredTextFirstPlayer) && (answeredTextSecondPlayer))
            text = [NSString stringWithFormat:
                    @"%@\n\n"
                    "%@: %@\n"
                    , relatedQuestion.text,
                    [opponent name],
                    @"???"
                    ];
        else
            text = [NSString stringWithFormat:
                    @"%@\n\n"
                    "%@: %@\n"
                    , relatedQuestion.text,
                    [player name],
                    @"Unanswered"
                    ];
    }
    return text;
}

- (NSUInteger)playerScore {
    NSUInteger score = [[[ServiceLayer instance] matchService] scoreForMatch:[self match] andUser:[Player instance]];
    return score;
}

- (NSUInteger)opponentScore {
    NSUInteger score = [[[ServiceLayer instance] matchService] scoreForMatch:[self match] andUser:[self opponent]];
    return score;
}

- (RLMResults<UserAnswer*>*)lastPlayerUserAnswers {
    // Get current round id
    Round* currentRound = [[[ServiceLayer instance] roundService] currentRoundforMatch:[self match]];
    long long roundID = currentRound.ID;

    // check out unsynchronized UserAnswers
    RLMResults* lastPlayerUserAnswersRealm = [UserAnswer objectsWhere: @"relatedUserID == %lld AND relatedRoundID == %lld", [Player instance].ID, roundID];
    
    // If no unsynch UserAnswers, return empty array
    return lastPlayerUserAnswersRealm;
}

@end
