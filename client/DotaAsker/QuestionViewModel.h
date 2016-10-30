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
@interface QuestionViewModel : NSObject

- (Question*)questionForQuestionIndex:(NSUInteger)index onTheme:(Theme*)theme inRound:(Round*)round;
- (User*)opponent;
- (Match*)currentMatchForRound:(Round*)round;

@end
