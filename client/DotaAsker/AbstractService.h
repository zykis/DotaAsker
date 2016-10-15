//
//  AbstractService.h
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACReplaySubject;
@interface AbstractService : NSObject

- (RACReplaySubject*)obtain:(unsigned long long) entityID;
- (RACReplaySubject*)obtainAll;
- (void)remove:(unsigned long long) entityID;
- (RACReplaySubject*)update:(id) entity;
- (RACReplaySubject*)create:(id) entity;

@end
