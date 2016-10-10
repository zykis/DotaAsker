//
//  AuthorizationService.h
//  DotaAsker
//
//  Created by Artem on 21/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "AbstractService.h"

@class User;
@class RACReplaySubject;

@interface AuthorizationService : AbstractService

@property (strong, nonatomic) NSString* accessToken;

- (RACReplaySubject*)signUpWithLogin:(NSString*)login andPassword:(NSString*)password email:(NSString*)email;
- (RACReplaySubject*)getTokenForUsername:(NSString*)username andPassword:(NSString*)password;

@end
