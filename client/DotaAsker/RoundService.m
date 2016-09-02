//
//  RoundService.m
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "RoundService.h"
#import "Round.h"
#import "RoundParser.h"
#import "RoundTransport.h"

@implementation RoundService

@synthesize transport;
@synthesize parser;
@synthesize cache;

- (id)init {
    self = [super init];
    if(self) {
        parser = [[RoundParser alloc] init];
        cache = [[AbstractCache alloc] init];
        transport = [[RoundTransport alloc] init];
    }
    return self;
}

+ (RoundService*)instance {
    static RoundService *roundService = nil;
    @synchronized(self) {
        if(roundService == nil)
            roundService = [[self alloc] init];
    }
    return roundService;
}

- (void)setQuestions:(NSArray *)questions forRound:(Round *)round {
    for (int i = 0; i < [questions count]; i++) {
        Question* q = [questions objectAtIndex:i];
        [[round questionsIDs] addObject:[NSNumber numberWithUnsignedLongLong:[q ID]]];
    }
    [self update:round];
}

- (Round*)currentRoundforMatch:(Match *)match {
    for (unsigned long i = [[match roundsIDs] count] - 1; ; i--) {
        Round *r = [self obtain:[[[match roundsIDs] objectAtIndex:i] integerValue]];
        if ([r round_state] != ROUND_NOT_STARTED) {
            return r;
        }
    }
    return nil;
}

- (Round*)roundAtIndex:(NSInteger)index inMatch:(Match *)match {
    if (index >= [[match roundsIDs] count]) {
        return nil;
    }
    NSInteger roundID = [[[match roundsIDs] objectAtIndex:index] integerValue];
    Round* r = [self obtain:roundID];
    return r;
}

@end
