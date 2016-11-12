//
//  UserTransport.h
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "Transport.h"

@class User;
@interface UserTransport : Transport

- (RACReplaySubject*)obtainWithAccessToken:(NSString *)accessToken;
- (RACReplaySubject*)obtain:(unsigned long long)entityID;
- (RACReplaySubject*)sendFriendtoUserData: (NSData*)to_user_data withAccessToken: (NSString*)accessToken;

@end
