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
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:value];
    NSDateFormatter* toFormatter = [[NSDateFormatter alloc] init];
    [toFormatter setDateFormat:@"dd.MM"];
    NSString* res = [toFormatter stringFromDate:date];
    return res;
}

@end
