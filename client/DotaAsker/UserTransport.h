//
//  UserTransport.h
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "Transport.h"

@interface UserTransport : Transport

- (RACReplaySubject*)obtainWithAccessToken:(NSString *)accessToken;
- (RACReplaySubject*)obtain:(unsigned long long)entityID;

@end
