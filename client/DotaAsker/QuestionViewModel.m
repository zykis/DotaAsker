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
    Match* currentMatch = [self currentMatchForRound:round];
    User* opponent;
    for (User* u in [currentMatch users]) {
        if (![u isEqual: [Player instance]]) {
            opponent = u;
        }
    }
    
    return opponent;
}

- (Match*)currentMatchForRound:(Round *)round {
    for (Match* m in [[Player instance] currentMatches]) {
        for (Round* r in [m rounds]) {
            if ([r isEqual:round]) {
                return m;
            }
        }
    }
    
    assert(NULL);
    return NULL;
}

@end
