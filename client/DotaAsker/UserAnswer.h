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
@property (strong, nonatomic) NSDate* createdOn;
@property (strong, nonatomic) NSDate* updatedOn;

@property (assign, nonatomic) NSInteger secForAnswer;
@property (assign, nonatomic) BOOL synchronized;

@property (assign, nonatomic) NSInteger relatedAnswerID;
@property (assign, nonatomic) NSInteger relatedUserID;
@property (assign, nonatomic) NSInteger relatedQuestionID;
@property (assign, nonatomic) NSInteger relatedRoundID;

- (Answer*) relatedAnswer;
- (User*) relatedUser;
- (Question*) relatedQuestion;
- (Round*) relatedRound;
    
@end
RLM_ARRAY_TYPE(UserAnswer)
