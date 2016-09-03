//
//  ThemeService.m
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "ThemeService.h"
#import "ThemeParser.h"
#import "ThemeTransport.h"

@implementation ThemeService

- (id)init {
    self = [super init];
    return self;
}

- (UIImage*)imageForTheme:(Theme *)theme {
    UIImage* image = [UIImage imageNamed:[theme imageName]];
    return image;
}

- (Theme*)themeForRound:(Round *)round {
    unsigned long long themeID = [round themeID];
    Theme* theme = [self obtain:themeID];
    return theme;
}

+ (ThemeService*)instance {
    static ThemeService *themeService = nil;
    @synchronized(self) {
        if(themeService == nil)
            themeService = [[self alloc] init];
    }
    return themeService;
}

@end
