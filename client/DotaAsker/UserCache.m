//
//  UserCache.m
//  DotaAsker
//
//  Created by Artem on 06/10/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "UserCache.h"
#import "User.h"

@implementation UserCache

- (BOOL)equal:(id)leftEntity to:(id)rightEntity {
    if ([(User*)leftEntity ID] == [(User*)rightEntity ID]) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
