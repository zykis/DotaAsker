//
//  Round.h
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

#define QUESTIONS_IN_ROUND 3

@class User;
@class Theme;

RLM_ARRAY_TYPE(Question)
RLM_ARRAY_TYPE(UserAnswer)

@interface Round : RLMObject

@property (assign, nonatomic) long long ID;
@property (strong, nonatomic) User* nextMoveUser;
@property (strong, nonatomic) RLMArray<Question*><Question>* questions;//список вопросов
@property (strong, nonatomic) RLMArray<UserAnswer*><UserAnswer>* userAnswers;//список ответов
@property (strong, nonatomic) Theme* selectedTheme;

@end
