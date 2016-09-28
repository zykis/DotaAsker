//
//  MainViewModel.h
//  DotaAsker
//
//  Created by Artem on 27/09/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Match;
@class User;

@interface MainViewModel : NSObject

- (NSUInteger)currentMatchesCount;
- (NSUInteger)recentMatchesCount;
- (NSString*)playerImagePath;
- (NSString*)opponentImagePathForCurrentMatch: (NSUInteger)row;
- (NSString*)opponentImagePathForRecentMatch: (NSUInteger)row;
- (NSString*)playerName;
- (NSUInteger)playerMMR;
- (NSUInteger)playerKDA;
- (NSUInteger)playerGPM;
- (NSString*)matchStateTextForCurrentMatch: (NSUInteger)row;
- (NSString*)matchStateTextForRecentMatch: (NSUInteger)row;
- (NSString*)opponentNameForCurrentMatch: (NSUInteger)row;
- (NSString*)opponentNameForRecentMatch: (NSUInteger)row;

- (Match*)recentMatchAtRow: (NSUInteger)row;
- (Match*)currentMatchAtRow: (NSUInteger)row;
@end
