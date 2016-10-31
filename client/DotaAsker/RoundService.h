//
//  RoundService.h
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AbstractService.h"
#import "Round.h"
@class Match;
@class User;
@class Question;
@class Round;
@class RoundTransport;

@interface RoundService : AbstractService

@property (strong, nonatomic) RoundTransport* transport;
- (Round*)currentRoundforMatch:(Match*)match;
- (Theme*)themeSelectedForRound:(Round*)round;
- (NSArray*)themesForRound:(Round*)round;
- (Question*)questionAtIndex:(NSUInteger)index onTheme:(Theme*)theme inRound:(Round*)round;

@end
