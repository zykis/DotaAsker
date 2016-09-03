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
+ (AuthorizationService*)instance;

@property (strong, nonatomic) NSString* accessToken;
@property (strong, nonatomic) User* user;

- (BOOL)signInWithLogin:(NSString*)login andPassword:(NSString*)password errorString:(NSString**)errorStr;
- (RACReplaySubject*)signUpWithLogin:(NSString*)login andPassword:(NSString*)password email:(NSString*)email;
- (RACReplaySubject*)getTokenForUsername:(NSString*)username andPassword:(NSString*)password;
- (BOOL)signInWithToken:(NSString*)token;

@end
