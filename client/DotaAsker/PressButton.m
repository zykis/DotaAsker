//
//  PressButton.m
//  DotaAsker
//
//  Created by Artem on 25/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "PressButton.h"
#import "AZButton.h"

@implementation PressButton

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [AZButton drawCanvas1WithIcon:[UIImage imageNamed:@"premium_48.png"] caption:@"Unlock premium" rect:self.bounds];
}


@end
