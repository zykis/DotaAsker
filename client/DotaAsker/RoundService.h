//
//  RoundService.h
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AbstractService.h"
#import "Question.h"
#import "Round.h"
#import "User.h"
#import "Match.h"

@interface RoundService : AbstractService
+ (RoundService*)instance;

- (void)setQuestions:(NSArray*)questions forRound:(Round*)round;
- (Round*)currentRoundforMatch:(Match*)match;
- (Round*)roundAtIndex:(NSInteger)index inMatch:(Match*)match;

@end
