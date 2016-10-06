//
//  MatchViewModel.h
//  DotaAsker
//
//  Created by Artem on 01/10/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Round.h"
#import "Match.h"

@interface MatchViewModel : NSObject

@property (strong, nonatomic) Match* match;
- (NSString*)playerImagePath;
- (NSString*)opponentImagePath;
- (NSString*)playerName;
- (NSString*)opponentName;
- (NSUInteger)playerScore;
- (NSUInteger)opponentScore;
- (NSUInteger)answerStateforRoundInRow:(NSUInteger)row andAnswerIndex:(NSUInteger)index forPlayer:(BOOL)bPlayer;
- (Round_State)roundStateForRoundInRow:(NSUInteger)row;
- (MatchState)matchState;
- (Round_State)roundStateForCurrentRound;
- (NSUInteger)playerAnswersCountForRoundInRow:(NSUInteger)row;
- (NSString*)textForUserAnswerForRoundInRow: (NSUInteger)row andUserAnswerIndex:(NSUInteger)index;

@end
