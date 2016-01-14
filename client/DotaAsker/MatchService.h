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


- (UIImage*)currentRoundThemeImageForMatch:(Match*)match;
- (NSArray*)currentMatchesOfPlayer:(Player*)player;
- (NSArray*)recentMatchesOfPlayer:(Player*)player;
- (Match*)findMatch;

@end
