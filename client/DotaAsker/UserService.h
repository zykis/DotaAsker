//
//  UserService.h
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AbstractService.h"
#import "User.h"
#import "Match.h"
@import UIKit;

@interface UserService : AbstractService

- (UIImage*)wallpapersDefault;
- (UIImage*)avatarForUser:(User*)user;
- (User*)obtainWithUsername:(NSString*)username;
- (User*)opponentForMatch:(Match*)match;
- (User*)playerForMatch:(Match*)match;

@end
