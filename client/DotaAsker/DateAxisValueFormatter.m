//
//  DateAxisValueFormatter.m
//  DotaAsker
//
//  Created by Artem on 15/04/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import "DateAxisValueFormatter.h"

@implementation DateAxisValueFormatter

- (NSString*)stringForValue:(double)value axis:(ChartAxisBase *)axis {
    return [NSString stringWithFormat:@"%f", value];
}

@end
