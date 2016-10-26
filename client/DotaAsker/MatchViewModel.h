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

@class User;
@interface MatchViewModel : NSObject

@property (strong, nonatomic) Match* match;
- (User*)opponent;
- (User*)nextMoveUser;
- (NSString*)roundStatusTextForRoundInRow:(NSUInteger)row;
- (NSUInteger)answerStateforRoundInRow:(NSUInteger)row andAnswerIndex:(NSUInteger)index;
- (NSString*)textForUserAnswerForRoundInRow:(NSUInteger)row andUserAnswerIndex:(NSUInteger)index;
- (NSUInteger)playerScore;
- (NSUInteger)opponentScore;

@end
