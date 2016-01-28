//
//  AuthorizationService.h
//  DotaAsker
//
//  Created by Artem on 21/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "AbstractService.h"
#import "Transport.h"
#import "User.h"

@interface AuthorizationService : AbstractService
+ (AuthorizationService*)instance;

@property (strong, nonatomic) Transport *transport;
@property (strong, nonatomic) NSString* accessToken;
@property (assign, nonatomic) NSInteger sessionID;
@property (strong, nonatomic) User* user;

- (BOOL)authWithLogin:(NSString*)login andPassword:(NSString*)password errorString:(NSString**)errorStr;
- (BOOL)signUpWithLogin:(NSString*)login andPassword:(NSString*)password email:(NSString*)email errorString:(NSString**)errorStr;
- (BOOL)fitsUsername:(NSString*)username andPassword:(NSString*)password error:(NSString**)error;

@end
