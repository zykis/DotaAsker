//
//  ThemeButton.m
//  DotaAsker
//
//  Created by Artem on 10/03/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import "ThemeButton.h"
#import "Palette.h"

IB_DESIGNABLE
@implementation ThemeButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.backgroundColor = [[Palette shared] themesButtonColor].CGColor;
        self.layer.cornerRadius = 8.0;
        self.layer.borderWidth = 2;
        self.layer.opacity = 0.85;
        self.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor;
    }
    return self;
}

@end
