//
//  Round.m
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "Round.h"
#import "User.h"

@implementation Round

- (id)init {
    self = [super init];
    if (self) {
        self.modified = NO;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    Round* r = object;
    if (r.ID == self.ID) {
        return YES;
    }
    return NO;
}

+ (NSArray *)ignoredProperties {
    return @[];
}

+ (NSString*)primaryKey {
    return @"ID";
}

- (User*)nextMoveUser {
    return [User objectForPrimaryKey:@(self.nextMoveUserID)];
}

@end
