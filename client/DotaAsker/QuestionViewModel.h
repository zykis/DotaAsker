//
//  QuestionViewModel.h
//  DotaAsker
//
//  Created by Artem on 29/10/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Theme;
@class Question;
@class User;
@class Round;
@class Match;
@class UserAnswer;
@interface QuestionViewModel : NSObject

- (Question*)questionForQuestionIndex:(NSUInteger)index onTheme:(Theme*)theme inRound:(Round*)round;
- (User*)opponentForRound:(Round*)round;
- (Match*)matchForRound:(Round*)round;
- (BOOL)isRoundLast:(Round*)round;
- (NSMutableArray*)lastPlayerUserAnswersForRound:(Round*)round;
- (UserAnswer*)lastPlayerUserAnswerForRound:(Round*)round;

@end
