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

- (NSMutableArray*)currentMatchesOfUser:(User *)user {
    NSArray* matchesIDs = [user currentMatchesIDs];
    NSMutableArray* currentMatches = [[NSMutableArray alloc] init];
    for (NSNumber *num in matchesIDs) {
        Match* m = [self obtain:[num integerValue]];
        if (m) {
            [currentMatches addObject:m];
        }
    }
    return currentMatches;
}

- (NSMutableArray*)recentMatchesOfUser:(User *)user {
    NSArray* matchesIDs = [user recentMatchesIDs];
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
    SEL findMatch = NSSelectorFromString(@"findMatch");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSData* jsonData = [transport performSelector:findMatch];
#pragma clang diagnostic pop
    if (!jsonData) {
        return nil;
    }
    NSError *error;
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    Match* m;
    if (!error) {
        m = [parser parse:dict];
    }
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
