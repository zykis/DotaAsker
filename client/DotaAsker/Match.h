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

#define MATCH_RUNNING 0
#define MATCH_FINISHED 1
#define MATCH_TIME_ELAPSED 2

#define CURRENT_MATCH 0
#define WAITING_MATCH 1
#define RECENT_MATCH 2

@class User;

@interface Match : NSObject

@property (assign, nonatomic) unsigned long long ID;
@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSMutableArray *rounds;
@property (assign, nonatomic) NSUInteger state;
@property (assign, nonatomic) NSUInteger mmrGain;

@end
