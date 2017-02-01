//
//  Transport.h
//  DotaAsker
//
//  Created by Artem on 17/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
    #define kAPIEndpointHost @"http://192.168.100.24:5000"
#else
    #define kAPIEndpointHost @""
#endif

@class RACReplaySubject;

#define kAPIEndpointHost @"http://185.156.179.139:80"

@interface Transport : NSObject

- (RACReplaySubject*)obtain:(unsigned long long) entityID;
- (RACReplaySubject*)obtainAll;
- (RACReplaySubject*)update:(NSData*) entityData;
- (RACReplaySubject*)create:(NSData*) entityData;

@end
