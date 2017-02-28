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
    Match* m = [[Match objectsWhere:@"ANY rounds.ID = %lld", round.ID] firstObject];
    assert(m);
    return m;
}

- (BOOL)isRoundLast:(Round *)round {
    Match* m = [self matchForRound:round];
    if ([[[m rounds] objectAtIndex:5] isEqual:round]) {
        return YES;
    }
    return NO;
}

- (RLMResults<UserAnswer*>*)lastPlayerUserAnswersForRound:(Round *)round {
    // Get current round id
    long long roundID = round.ID;

    // check out unsynchronized UserAnswers
    RLMResults<UserAnswer*>* lastPlayerUserAnswersRealm = [UserAnswer objectsWhere: [NSString stringWithFormat:@"synchronized == 0 && relatedUserID == %lld && relatedRoundID == %lld", [Player instance].ID, roundID]];
    
    // If no unsynch UserAnswers, return empty array
    return lastPlayerUserAnswersRealm;
}

- (UserAnswer*)lastPlayerUserAnswerForRound:(Round *)round {
    RLMResults<UserAnswer*>* lastUserAnswers = [self lastPlayerUserAnswersForRound:round];
    if ([lastUserAnswers count] == 0)
        return nil;
    else {
        return [lastUserAnswers lastObject];
    }
}

@end
