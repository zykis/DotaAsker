//
//  PercentValueFormatter.m
//  DotaAsker
//
//  Created by Artem on 15/04/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import "PercentValueFormatter.h"

@implementation PercentValueFormatter

- (NSString*)stringForValue:(double)value entry:(ChartDataEntry *)entry dataSetIndex:(NSInteger)dataSetIndex viewPortHandler:(ChartViewPortHandler *)viewPortHandler {
    return [NSString stringWithFormat:@"%.1f %%", value];
}

@end
