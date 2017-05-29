//
//  Match.h
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "Round.h"

#define ROUNDS_IN_MATCH 6

#define MATCH_RUNNING 0
#define MATCH_FINISHED 1

#define MATCH_FINISH_REASON_NONE 0
#define MATCH_FINISH_REASON_NORMAL 1
#define MATCH_FINISH_REASON_TIME_ELAPSED 2
#define MATCH_FINISH_REASON_SURREND 3

#define CURRENT_MATCH 0
#define WAITING_MATCH 1
#define RECENT_MATCH 2

typedef enum { kPlayer = 0, kOpponent, kDraw } Winner;

@class User;
RLM_ARRAY_TYPE(User)

@interface Match : RLMObject

@property long long ID;
@property NSDate* createdOn;
@property NSDate* updatedOn;
@property RLMArray<Round*><Round>* rounds;
@property RLMArray<User>* users;
@property User* winner;
@property NSInteger state;
@property NSInteger finishReason;
@property NSInteger mmrGain;
@property bool hidden;

@end
RLM_ARRAY_TYPE(Match)
