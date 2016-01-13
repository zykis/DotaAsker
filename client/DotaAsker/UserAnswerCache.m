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

- (id)init {
    self = [super init];
    if (self) {
        self.entities = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)appendEntities:(NSArray *)entities {
    for (int i = 0; i < [entities count]; i++) {
        if (![self.entities containsObject:[entities objectAtIndex:i]]) {
            [self.entities addObject:[entities objectAtIndex:i]];
        }
    }
}

- (NSArray*)obtainAll {
    return self.entities;
}

- (UserAnswer*)obtain:(NSInteger)anID {
    for (int i = 0; i < [[self entities] count]; i++) {
        if([[[self entities] objectAtIndex:i] ID] == anID) {
            return [[self entities] objectAtIndex:i];
        }
    }
    return nil;
}

- (void)append:(UserAnswer *)userAnswer {
    [self appendEntities: [NSArray arrayWithObject:userAnswer]];
}

- (UserAnswer*)update:(UserAnswer *)userAnswer {
    if([[self entities] containsObject:userAnswer]) {
        NSInteger ind = [[self entities] indexOfObject:userAnswer];
        [[self entities] replaceObjectAtIndex:ind withObject:userAnswer];
    }
    return userAnswer;
}

- (void)remove:(NSInteger)anID {
    for (int i = 0; i < [[self entities] count]; i++) {
        if([[[self entities] objectAtIndex:i] ID] == anID) {
            [[self entities] removeObjectAtIndex:i];
            return;
        }
    }
}

@end
