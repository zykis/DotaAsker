//
//  Palette.m
//  DotaAsker
//
//  Created by Artem on 07/03/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import "Palette.h"

@implementation Palette

+ (Palette*)shared {
    static Palette *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Palette alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

@end
