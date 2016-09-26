//
//  Round.m
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "Round.h"

@implementation Round

- (id)init {
    self = [super init];
    if (self) {
        self.questions = [[NSMutableArray alloc] init];
        self.userAnswers = [[NSMutableArray alloc] init];
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

@end
