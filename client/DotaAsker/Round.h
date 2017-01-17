//
//  Round.h
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "Question.h"
#import "UserAnswer.h"

#define QUESTIONS_IN_ROUND 3

@class User;
@class Theme;

@interface Round : RLMObject

@property (assign, nonatomic) long long ID;
@property User* nextMoveUser;
@property RLMArray<Question*><Question>* questions;
@property RLMArray<UserAnswer*><UserAnswer>* userAnswers;
@property Theme* selectedTheme;

@end
RLM_ARRAY_TYPE(Round)
