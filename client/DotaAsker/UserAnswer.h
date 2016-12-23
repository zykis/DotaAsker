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
@property (strong, nonatomic) Answer* relatedAnswer;
@property (strong, nonatomic) Round* relatedRound;
@property (strong, nonatomic) User* relatedUser;
@property (strong, nonatomic) Question* relatedQuestion;
@property (assign, nonatomic) BOOL synchronized;
    
@end
