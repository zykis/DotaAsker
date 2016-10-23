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

@interface RoundService : AbstractService

- (Round*)currentRoundforMatch:(Match*)match;

@end
