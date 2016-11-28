//
//  PressButton.m
//  DotaAsker
//
//  Created by Artem on 25/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "PressButton.h"
#import "PressButtonStyleKit.h"

@implementation PressButton

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [PressButtonStyleKit drawButtonWithIcon:self.icon caption:self.caption rect:self.bounds fontSize:self.fontSize rectIcon:self.iconRect];
    
}


@end
