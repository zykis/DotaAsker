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

@class MatchTransport;
@class RACReplaySubject;
@class AuthorizationService;

@interface MatchService : AbstractService

@property (strong, nonatomic) MatchTransport* transport;
@property (strong, nonatomic) AuthorizationService* authorizationService;

- (RACReplaySubject*)findMatchForUser: (NSString*)accessToken;
- (RACReplaySubject*)finishMatch: (Match*)match;

- (NSUInteger)scoreForMatch:(Match*)m andUser:(User*)u;
- (User*)nextMoveUserInMatch:(Match*)match;

- (RACReplaySubject*)surrendAtMatch: (Match*)match;

@end
