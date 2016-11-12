//
//  AbstractService.m
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "AbstractService.h"

@implementation AbstractService
//- (RACReplaySubject*)obtain:(unsigned long long) entityID;
//- (RACReplaySubject*)obtainAll;
//- (void)remove:(unsigned long long) entityID;
//- (RACReplaySubject*)update:(id) entity;
//- (RACReplaySubject*)create:(id) entity;

- (RACReplaySubject*)obtain:(unsigned long long)entityID {
    assert(0);
}

- (RACReplaySubject*)obtainAll {
    assert(0);
}

- (void)remove:(unsigned long long)entityID {
    assert(0);
}

- (RACReplaySubject*)update:(id)entity {
    assert(0);
}

- (RACReplaySubject*)create:(id)entity {
    assert(0);
}

@end
