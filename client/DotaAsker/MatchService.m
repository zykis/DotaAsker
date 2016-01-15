//
//  MatchService.m
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "MatchService.h"
#import "MatchParser.h"
#import "MatchTransport.h"

@implementation MatchService

@synthesize transport;
@synthesize parser;
@synthesize cache;

- (id)init {
    self = [super init];
    if(self) {
        parser = [[MatchParser alloc] init];
        cache = [[AbstractCache alloc] init];
        transport = [[MatchTransport alloc] init];
    }
    return self;
}

+ (MatchService*)instance {
    static MatchService *matchService = nil;
    @synchronized(self) {
        if(matchService == nil)
            matchService = [[self alloc] init];
    }
    return matchService;
}

- (NSArray*)currentMatchesOfPlayer:(Player *)player {
    NSArray* matchesIDs = [player currentMatchesIDs];
    NSMutableArray* currentMatches = [[NSMutableArray alloc] init];
    for (NSNumber *num in matchesIDs) {
        Match* m = [self obtain:[num integerValue]];
        if (m) {
            [currentMatches addObject:m];
        }
    }
    return currentMatches;
}

- (NSArray*)recentMatchesOfPlayer:(Player *)player {
    NSArray* matchesIDs = [player recentMatchesIDs];
    NSMutableArray* recentMatches = [[NSMutableArray alloc] init];
    for (NSNumber *num in matchesIDs) {
        Match* m = [self obtain:[num integerValue]];
        if (m) {
            [recentMatches addObject:m];
        }
    }
    return recentMatches;
}

- (Match*)findMatch {
    Match* m = [self obtain:0];
    return m;
}

- (Match*)matchForRound:(Round *)round {
    NSArray* matches = [self obtainAll];
    for (Match* m in matches) {
        if ([[m roundsIDs] containsObject:[NSNumber numberWithUnsignedLongLong:[round ID]]]) {
            return m;
        }
    }
    return nil;
}

@end
