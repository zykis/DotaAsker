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
- (NSString*)matchStateTextForCurrentMatch: (NSUInteger)row;
- (NSString*)matchStateTextForRecentMatch: (NSUInteger)row;
- (User*)opponentForCurrentMatch: (NSUInteger)row;
- (User*)opponentForRecentMatch: (NSUInteger)row;

- (Match*)recentMatchAtRow: (NSUInteger)row;
- (Match*)currentMatchAtRow: (NSUInteger)row;
@end
