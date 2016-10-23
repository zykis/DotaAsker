//
//  RoundService.m
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "RoundService.h"
#import "RoundParser.h"
#import "Match.h"
#import "User.h"
#import "Round.h"

@implementation RoundService

- (Round*)currentRoundforMatch:(Match *)match {
    if (match.finished) {
        int index = 0;
        for (Round* r in match.rounds) {
            if ([[r userAnswers] count] == 6) {
                index++;
            }
        }
        if (index == 6) index--;
        return [match.rounds objectAtIndex:index];
    }
    int i;
    for (i = 0; i < [[match rounds] count]; i++) {
        Round* r = [[match rounds] objectAtIndex:i];
        if ([[r userAnswers] count] != QUESTIONS_IN_ROUND * 2)
            break;
    }
    if (i == 6) i--;
    
    return [[match rounds] objectAtIndex:i];
}

@end
