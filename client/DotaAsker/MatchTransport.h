//
//  MatchTransport.h
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "Transport.h"
#import "Match.h"

@class RACReplaySubject;

@interface MatchTransport : Transport

- (RACReplaySubject*)findMatchForUser:(NSString*)accessToken;
- (RACReplaySubject*)finishMatch:(NSData*)matchData;
- (RACReplaySubject*)surrendAtMatchData: (NSData*)matchData andAccessToken:(NSString*)accessToken;

@end
