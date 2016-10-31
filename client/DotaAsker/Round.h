//
//  Round.h
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Theme.h"

#define QUESTIONS_IN_ROUND 3

@class User;
@interface Round : NSObject

@property (assign, nonatomic) unsigned long long ID;
@property (strong, nonatomic) User* nextMoveUser;
@property (strong, nonatomic) NSMutableArray* questions;//список вопросов
@property (strong, nonatomic) NSMutableArray* userAnswers;//список ответов

@end
