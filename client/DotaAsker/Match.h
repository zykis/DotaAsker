//
//  Match.h
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
//#import "User.h"
#import "Round.h"

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
RLM_ARRAY_TYPE(User)
@class Round;

@interface Match : RLMObject

@property (assign, nonatomic) long long ID;
@property RLMArray<User>* users;
@property (strong, nonatomic) RLMArray<Round>* rounds;
@property (assign, nonatomic) NSInteger state;
@property (assign, nonatomic) NSInteger mmrGain;
@property (strong, nonatomic) NSString* updatedOn;

@end
RLM_ARRAY_TYPE(Match)
