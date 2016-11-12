//
//  AbstractCache.m
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "AbstractCache.h"

@implementation AbstractCache

@synthesize entities;

- (id)init {
    self = [super init];
    if (self) {
        self.entities = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)appendEntities:(NSArray *)entities {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wshadow-ivar"
    for (int i = 0; i < [entities count]; i++) {
        if (![self.entities containsObject:[entities objectAtIndex:i]]) {
            [self.entities addObject:[entities objectAtIndex:i]];
        }
    }
#pragma GCC diagnostic pop
}

- (NSArray*)allEntities {
    return self.entities;
}

- (void)append:(id)entity {
    [self appendEntities: [NSArray arrayWithObject:entity]];
}

- (id)update:(id)entity {
    if([[self entities] containsObject:entity]) {
        NSInteger ind = [[self entities] indexOfObject:entity];
        [[self entities] replaceObjectAtIndex:ind withObject:entity];
    }
    return entity;
}

@end
