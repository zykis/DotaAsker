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

- (NSArray*)obtainAll {
    return self.entities;
}

- (id)obtain:(unsigned long long)anID {
    SEL selector = NSSelectorFromString(@"ID");
    for (int i = 0; i < [[self entities] count]; i++) {
        id entity = [[self entities] objectAtIndex:i];
        if ([entity respondsToSelector:selector]) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                        [[entity class] instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:entity];
            [invocation invoke];
            NSInteger returnValue;
            [invocation getReturnValue:&returnValue];
            if(returnValue == anID) {
                return [[self entities] objectAtIndex:i];
            }
        }
    }
    return nil;
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

- (void)remove:(unsigned long long)anID {
    SEL selector = NSSelectorFromString(@"getID");
    for (int i = 0; i < [[self entities] count]; i++) {
        id entity = [[self entities] objectAtIndex:i];
        if ([entity respondsToSelector:selector]) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                        [[entity class] instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:entity];
            [invocation invoke];
            NSInteger returnValue;
            [invocation getReturnValue:&returnValue];
            if(returnValue == anID) {
                [[self entities] removeObjectAtIndex:i];
                return;
            }
        }
    }
}

@end
