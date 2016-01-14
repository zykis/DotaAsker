//
//  AuthorizationService.h
//  DotaAsker
//
//  Created by Artem on 21/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "AbstractService.h"
#import "Transport.h"

@interface AuthorizationService : AbstractService

@property (strong, nonatomic) Transport *transport;
@property (strong, nonatomic) NSString* accessToken;
@property (assign, nonatomic) NSInteger sessionID;
- (BOOL)authWithLogin:(NSString*)login andPassword:(NSString*)password errorString:(NSString**)errorStr;
- (BOOL)signUpWithLogin:(NSString*)login andPassword:(NSString*)password email:(NSString*)email errorString:(NSString**)errorStr;

@end
