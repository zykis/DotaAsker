//
//  Match.m
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "Match.h"

@implementation Match

- (id)init {
    self = [super init];
    if (self) {
        self.users = [[NSMutableArray alloc] init];
        self.rounds = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    Match* m = object;
    if (m.ID == self.ID) {
        return YES;
    }
    return NO;
}

@end
