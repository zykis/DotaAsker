//
//  MatchService.h
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AbstractService.h"
#import "Match.h"
#import "Round.h"
#import "User.h"
#import "Player.h"
@import UIKit;

@interface MatchService : AbstractService
+ (MatchService*)instance;

- (NSArray*)currentMatchesOfUser:(User*)user;
- (NSArray*)recentMatchesOfUser:(User*)user;
- (Match*)findMatch;
- (Match*)matchForRound:(Round*)round;

@end
