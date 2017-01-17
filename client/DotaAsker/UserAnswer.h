//
//  Answer.h
//  DotaAsker
//
//  Created by Artem on 02/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@class Question;
@class Answer;
@class Round;
@class User;

@interface UserAnswer: RLMObject

@property (assign, nonatomic) long long ID;
@property (assign, nonatomic) NSInteger secForAnswer;
@property Answer* relatedAnswer;
@property User* relatedUser;
@property Question* relatedQuestion;
@property Round* relatedRound;
@property (assign, nonatomic) BOOL synchronized;
    
@end
RLM_ARRAY_TYPE(UserAnswer)
