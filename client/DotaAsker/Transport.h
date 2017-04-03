//
//  Transport.h
//  DotaAsker
//
//  Created by Artem on 17/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define kAPIEndpointHost @"http://185.156.179.139:80"
#define kAPIEndpointHost @"localhost:5000"

@class RACReplaySubject;

@interface Transport : NSObject

- (RACReplaySubject*)obtain:(unsigned long long) entityID;
- (RACReplaySubject*)obtainAll;
- (RACReplaySubject*)update:(NSData*) entityData;
- (RACReplaySubject*)create:(NSData*) entityData;

@end
