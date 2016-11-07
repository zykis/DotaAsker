//
//  APIHelper.m
//  DotaAsker
//
//  Created by Artem on 23/09/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "Helper.h"

@implementation Helper
/*
 Singleton instance to have an opportunity of early initialization
 of cache sizes and setting up current location
 */
+ (Helper*)shared {
    static Helper* instance = nil;
    @synchronized (self) {
        if (instance == nil) {
            instance = [[Helper alloc] init];
        }
    }
    return instance;
}

- (id)init {
    self = [super init];
    if(self) {
        //settting cache capacity
        NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                             diskCapacity:20 * 1024 * 1024
                                                                 diskPath:nil];
        [NSURLCache setSharedURLCache:URLCache];
    }
    return self;
}

- (CGSize)getQuestionImageViewSize {
    return CGSizeMake(351, 197);
}

@end

