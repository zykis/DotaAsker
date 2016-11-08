//
//  Answer.m
//  DotaAsker
//
//  Created by Artem on 22/09/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "Answer.h"
#import "Question.h"

@implementation Answer

- (id)init {
    self = [super init];
    if (self) {
        _ID = 0;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    Answer* a = object;
    if (a.ID == self.ID) {
        return YES;
    }
    return NO;
}

+ (Answer*)emptyAnswer {
    Answer* a = [[Answer alloc] init];
    a.text = [NSString stringWithFormat:@"Unanswered"];
    a.isCorrect = NO;
    a.ID = 0;
    return a;
}

@end
