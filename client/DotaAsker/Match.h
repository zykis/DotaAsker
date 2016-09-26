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
@class User;

@interface Match : NSObject

@property (assign, nonatomic) unsigned long long ID;
@property (assign, nonatomic) MatchState state;
@property (strong, nonatomic) User* opponent;
@property (assign, nonatomic) NSUInteger scorePlayer;
@property (assign, nonatomic) NSUInteger scoreOpponent;
@property (strong, nonatomic) NSMutableArray *rounds;

@end
