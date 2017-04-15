//
//  MainViewModel.h
//  DotaAsker
//
//  Created by Artem on 27/09/16.
//  Copyright © 2016 Artem. All rights reserved.
//


// Local
#import <Foundation/Foundation.h>
#import "Match.h"

// Libraries
#import <Realm/Realm.h>

@class User;
@class Theme;
@class Round;

@interface MainViewModel : NSObject

- (NSUInteger)currentMatchesCount;
- (NSUInteger)waitingMatchesCount;
- (NSUInteger)recentMatchesCount;
- (NSString*)matchStateTextForCurrentMatch: (NSUInteger)row;
- (NSString*)matchStateTextForWaitingMatch: (NSUInteger)row;
- (NSString*)matchStateTextForRecentMatch: (NSUInteger)row;
- (User*)opponentForCurrentMatch: (NSUInteger)row;
- (User*)opponentForWaitingMatch: (NSUInteger)row;
- (User*)opponentForRecentMatch: (NSUInteger)row;
- (User*)opponentForMatch: (Match*)match;
- (NSUInteger)matchSectionForMatch: (Match*)match;
- (NSArray*)currentMatches;
- (NSArray*)waitingMatches;
- (NSArray*)recentMatches;
- (NSInteger)mmrGainForRecentMatchAtRow: (NSUInteger)row;
- (Winner)winnerAtMatchAtRow:(NSUInteger)row;

- (Match*)recentMatchAtRow: (NSUInteger)row;
- (Match*)waitingMatchAtRow: (NSUInteger)row;
- (Match*)currentMatchAtRow: (NSUInteger)row;
@end
