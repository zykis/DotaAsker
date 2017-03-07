//
//  ThemeButton.m
//  DotaAsker
//
//  Created by Artem on 06/03/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import "ThemeButton.h"

@implementation ThemeButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.cornerRadius = 16;
    }
    return self;
}

@end
