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
#import "Round.h"

@class RACReplaySubject;
@class UserCache;
@class UserTransport;
@class UserParser;
@class AuthorizationService;

@interface UserService : AbstractService

@property (strong, nonatomic) UserCache* cache;
@property (strong, nonatomic) UserTransport *transport;
@property (strong, nonatomic) AuthorizationService *authorizationService;

- (RACReplaySubject*)obtain: (unsigned long long) ID;
- (RACReplaySubject*)obtainWithAccessToken:(NSString*)accessToken;
- (RACReplaySubject*)sendFriendRequestToUser:(User*)to_user;

@end
