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
@property (strong, nonatomic) User* nextMoveUser;
@property (strong, nonatomic) RLMArray<Question*><Question>* questions;//список вопросов
@property (strong, nonatomic) RLMArray<UserAnswer*><UserAnswer>* userAnswers;//список ответов
@property (strong, nonatomic) Theme* selectedTheme;

@end
RLM_ARRAY_TYPE(Round)
