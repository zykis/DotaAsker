//
//  Match.h
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ROUNDS_IN_MATCH 6
#define MIN_MMR_PRICE 15
#define MAX_MMR_PRICE 35

typedef enum {MATCH_NOT_STARTED = 0, MATCH_RUNNING, MATCH_FINISHED, MATCH_TIME_ELAPSED} MatchState;

@interface Match : NSObject

@property (assign, nonatomic) NSInteger ID;
@property (assign, nonatomic) NSInteger winnerID;
@property (assign, nonatomic) NSInteger playerID;
@property (assign, nonatomic) NSInteger opponentID;
@property (assign, nonatomic) MatchState state;
@property (assign, nonatomic) NSInteger scorePlayer;
@property (assign, nonatomic) NSInteger scoreOpponent;
@property (strong, nonatomic) NSMutableArray *roundsIDs;
@property (assign, nonatomic) BOOL synchronized;

@end
