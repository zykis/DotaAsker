//
//  Answer.m
//  DotaAsker
//
//  Created by Artem on 22/09/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "Answer.h"

@implementation Answer

- (BOOL)isEqual:(id)object {
    Answer* a = object;
    if (a.ID == self.ID) {
        return YES;
    }
    return NO;
}

@end
