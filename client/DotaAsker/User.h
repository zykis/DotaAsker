//
//  User.h
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "Match.h"

@import UIKit;

typedef enum {ROLE_USER=0, ROLE_ADMIN} ROLE;

@interface User : RLMObject

@property (assign, nonatomic) long long ID;
@property (strong, nonatomic) NSDate* createdOn;
@property (strong, nonatomic) NSDate* updatedOn;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *email;
@property (assign, nonatomic) NSInteger MMR;//Текущий рейтинг среди всех игроков
@property (assign, nonatomic) BOOL premium;
@property (assign, nonatomic) float KDA;//Отношение правильно отвеченных вопросов на неправильно отвеченные.
@property (assign, nonatomic) float GPM;//Насколько быстро вы отвечаете на вопросы
@property (strong, nonatomic) NSString *wallpapersImageName;
@property (strong, nonatomic) NSString *avatarImageName;
@property (assign, nonatomic) NSInteger totalCorrectAnswers;
@property (assign, nonatomic) NSInteger totalIncorrectAnswers;
@property (assign, nonatomic) NSInteger totalMatchesWon;
@property (assign, nonatomic) NSInteger totalMatchesLost;
@property (assign, nonatomic) NSInteger totalTimeForAnswers;
@property (assign, nonatomic) ROLE role;
@property RLMArray<Match>* matches;
@property RLMArray<User>* friends;

@end

//RLM_ARRAY_TYPE(User)
