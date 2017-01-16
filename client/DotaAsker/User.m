//
//  User.m
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "User.h"

@implementation User

- (id)init {
    self = [super init];
    if (self) {
        self.name = @"Opponent";
        self.avatarImageName = @"avatar_default.png";
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    User* user = object;
    if (user.ID == self.ID) {
        return YES;
    }
    return NO;
}

+ (NSArray*)ignoredProperties {
    return @[];
}

+ (NSString*)primaryKey {
    return @"ID";
}

@end
