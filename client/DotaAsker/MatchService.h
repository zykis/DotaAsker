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

@interface MatchService : AbstractService

@property (strong, nonatomic) MatchTransport* transport;

- (RACReplaySubject*)findMatchForUser: (NSString*)accessToken;

@end
