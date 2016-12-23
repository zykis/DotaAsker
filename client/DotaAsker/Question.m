//
//  Question.m
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "Question.h"
#import "Theme.h"

@implementation Question

- (BOOL)isEqual:(id)object {
    Question* q = object;
    if (q.ID == self.ID) {
        return YES;
    }
    return NO;
}

@end
