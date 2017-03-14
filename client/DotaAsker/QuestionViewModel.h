//
//  QuestionViewModel.h
//  DotaAsker
//
//  Created by Artem on 29/10/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "UserAnswer.h"

@class Theme;
@class Question;
@class User;
@class Round;
@class Match;

@interface QuestionViewModel : NSObject

- (Question*)questionForQuestionIndex:(NSUInteger)index onTheme:(Theme*)theme inRound:(Round*)round;
- (User*)opponentForRound:(Round*)round;
- (Match*)matchForRound:(Round*)round;
- (BOOL)isRoundLast:(Round*)round;
- (RLMResults<UserAnswer>*)playerAnswersForRound:(Round*)round;
- (UserAnswer*)lastPlayerUserAnswerForRound:(Round*)round;

@end
