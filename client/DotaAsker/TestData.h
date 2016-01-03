//
//  TestData.h
//  DotaAsker
//
//  Created by Artem on 01/08/15.
//  Copyright (c) 2015 Artem. All rights reserved.

#import <Foundation/Foundation.h>
@class Match;
@class Round;
@class Question;
@class UserAnswer;
@class Theme;
@class User;
@interface TestData : NSObject

+ (void)generateTestGameData;

+ (Match*)generateFinishedMatchVSUser: (User*)anOpponent;
+ (Match*)generateRunningMatchVSUser: (User*)anOpponent;
//+ (Match*)generateTimeElapsedMatchVSUser: (User*)anOpponent;
+ (Match*)generateNewMatchVSUser: (User*)anOpponent;
+ (Match*)generateFinishingMatchVSUser:(User *)anOpponent;

+ (void)generateNotStartedRound: (Round*)aRound;
+ (void)generateFinishedRound: (Round*)aRound;
+ (void)generatePlayerAnsweringRound: (Round*)aRound;
+ (void)generatePlayerReplyingRound: (Round*)aRound;
+ (void)generateOpponentAnsweringRound: (Round*)aRound;
//+ (void)generateOpponentReplyingRound: (Round*)aRound;
//+ (void)generateTimeElapsedRound: (Round*)aRound;

+ (Question*)generateQuestionOnTheme: (Theme*)aTheme;

@end
