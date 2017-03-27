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
@property (assign, nonatomic) BOOL modified;

@property (assign, nonatomic) long long relatedAnswerID;
@property (assign, nonatomic) long long relatedUserID;
@property (assign, nonatomic) long long relatedQuestionID;
@property (assign, nonatomic) long long relatedRoundID;

- (Answer*) relatedAnswer;
- (User*) relatedUser;
- (Question*) relatedQuestion;
- (Round*) relatedRound;
- (NSString*)description;
    
@end
RLM_ARRAY_TYPE(UserAnswer)
