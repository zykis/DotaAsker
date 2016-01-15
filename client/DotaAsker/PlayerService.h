//
//  PlayerService.h
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "UserService.h"
#import "Player.h"
@import UIKit;

@interface PlayerService : UserService
+ (PlayerService*)instance;

- (Player*)obtainPlayerWithUsername:(NSString*)username;

@end
