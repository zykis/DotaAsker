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
        self.currentMatchesIDs = [[NSMutableArray alloc] init];
        self.recentMatchesIDs = [[NSMutableArray alloc] init];
        self.friendsIDs = [[NSMutableArray alloc] init];
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

@end
