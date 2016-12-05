//
//  Answer.m
//  DotaAsker
//
//  Created by Artem on 02/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "UserAnswer.h"

@implementation UserAnswer

- (id)init {
    self = [super init];
    if (self) {
        self.synchronized = YES;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isMemberOfClass:[UserAnswer class]]) {
        UserAnswer* ua = object;
        if (ua.ID == self.ID)
            return YES;
    }
    return NO;
}

@end
