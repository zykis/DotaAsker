//
//  QuestionViewModel.m
//  DotaAsker
//
//  Created by Artem on 29/10/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "QuestionViewModel.h"
#import "Question.h"
#import "Answer.h"
#import "ServiceLayer.h"
#import "User.h"
#import "Round.h"
#import "Match.h"

@implementation QuestionViewModel

- (Question*)questionForQuestionIndex:(NSUInteger)index onTheme:(Theme *)theme inRound:(Round *)round {
    Question *currentQuestion = [[[ServiceLayer instance] roundService] questionAtIndex:index onTheme: theme inRound:round];
    return currentQuestion;
}

- (User*)opponentForRound:(Round*)round {
    Match* currentMatch = [self matchForRound:round];
    User* opponent;
    for (User* u in [currentMatch users]) {
        if (![u isEqual: [Player instance]]) {
            opponent = u;
        }
    }
    
    return opponent;
}

- (Match*)matchForRound:(Round *)round {
    for (Match* m in [[Player instance] matches]) {
        for (Round* r in [m rounds]) {
            if ([r isEqual:round]) {
                return m;
            }
        }
    }
    
    assert(NULL);
    return NULL;
}

- (BOOL)isRoundLast:(Round *)round {
    Match* m = [self matchForRound:round];
    if ([[[m rounds] objectAtIndex:5] isEqual:round]) {
        return YES;
    }
    return NO;
}

- (NSMutableArray*)lastPlayerUserAnswersForRound:(Round *)round {
    NSMutableArray* lastPlayerUserAnswers = [[NSMutableArray alloc] init];
    Round* currentRound = round;
    if ([[currentRound userAnswers] count] == 0)
        return lastPlayerUserAnswers;
    for (NSInteger i = [[currentRound userAnswers] count] - 1; i >= 0; i--) {
        UserAnswer* ua = [[currentRound userAnswers] objectAtIndex:i];
        if ([[ua relatedUser] isEqual:[Player instance]]) {
            [lastPlayerUserAnswers insertObject:ua atIndex:0];
        }
    }
    return lastPlayerUserAnswers;
}

- (UserAnswer*)lastPlayerUserAnswerForRound:(Round *)round {
    NSMutableArray* lastUserAnswers = [self lastPlayerUserAnswersForRound:round];
    if ([lastUserAnswers count] == 0)
        return nil;
    else {
        return [lastUserAnswers lastObject];
    }
}

@end
