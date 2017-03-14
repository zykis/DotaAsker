//
//  Match.m
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "Match.h"

@implementation Match

@synthesize createdOn = _createdOn;
@synthesize updatedOn = _updatedOn;

- (id)init {
    self = [super init];
    if (self) {
        self.createdOn = [NSDate date];
        self.updatedOn = [NSDate date];
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

+ (NSString*)primaryKey {
    return @"ID";
}

@end
