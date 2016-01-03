//
//  UserAnswerCache.m
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "UserAnswerCache.h"
#import "UserAnswer.h"

@implementation UserAnswerCache

- (BOOL)equal:(id)rightEntity to:(id)leftEntity {
    if (!([rightEntity isMemberOfClass:[UserAnswer class]] || [leftEntity isMemberOfClass:[UserAnswer class]])) {
        NSLog(@"entity is not a member of class \"UserAnswer\"");
        return NO;
    }
    UserAnswer* right = rightEntity;
    UserAnswer* left = leftEntity;
    if (right.ID == left.ID) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
