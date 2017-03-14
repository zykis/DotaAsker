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
    Round* selectedRound = [[[self match] rounds] objectAtIndex:row];
    
    User* player = [Player instance];
    User* opponent = [self opponent];
    
    RLMResults<UserAnswer*> *firstUserUserAnswers = [[UserAnswer objectsWhere:@"relatedRoundID == %lld AND relatedUserID == %lld", selectedRound.ID, player.ID] sortedResultsUsingKeyPath:@"ID" ascending:YES];
    RLMResults<UserAnswer*> *secondUserUserAnswers = [[UserAnswer objectsWhere:@"relatedRoundID == %lld AND relatedUserID == %lld", selectedRound.ID, opponent.ID] sortedResultsUsingKeyPath:@"ID" ascending:YES];
    UserAnswer* ua1;
    UserAnswer* ua2;
    if ([firstUserUserAnswers count] >= index + 1) {
        ua1 = [firstUserUserAnswers objectAtIndex:index];
        NSLog(@"UA tapped ID = %lld, questionID: %ld", ua1.ID, (long)ua1.relatedQuestionID);
    }
    if ([secondUserUserAnswers count] >= index + 1) {
        ua2 = [secondUserUserAnswers objectAtIndex:index];
    }

    NSString* text = [[[ServiceLayer instance] userAnswerService] textForUserAnswerFirst: ua1 andSecond: ua2];
    
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
