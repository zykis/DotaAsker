//
//  Theme.m
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "Theme.h"

@implementation Theme

- (BOOL)isEqual:(id)object {
    Theme* t = object;
    if (t.ID == self.ID) {
        return YES;
    }
    return NO;
}

+ (NSString*)primaryKey {
    return @"ID";
}

@end
