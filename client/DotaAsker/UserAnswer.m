//
//  Answer.m
//  DotaAsker
//
//  Created by Artem on 02/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "UserAnswer.h"
#import "User.h"
#import "Round.h"
#import "Question.h"

#import <Realm/Realm.h>

@implementation UserAnswer

@synthesize createdOn = _createdOn;
@synthesize updatedOn = _updatedOn;

- (id)init {
    self = [super init];
    if (self) {
        self.modified = NO;
        self.createdOn = [NSDate date];
        self.updatedOn = [NSDate date];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    UserAnswer* ua = object;
    return ([ua.relatedUser isEqual:self.relatedUser] && [ua.relatedRound isEqual:self.relatedRound] && [ua.relatedQuestion isEqual:self.relatedQuestion]);
}

+ (NSArray *)ignoredProperties {
    return @[];
}

+ (NSString*)primaryKey {
    return @"ID";
}

- (Answer*)relatedAnswer {
    return [Answer objectForPrimaryKey:@(self.relatedAnswerID)];
}

- (User*)relatedUser {
    return [User objectForPrimaryKey:@(self.relatedUserID)];
}

- (Question*)relatedQuestion {
    return [Question objectForPrimaryKey:@(self.relatedQuestionID)];
}

- (Round*)relatedRound {
    return [Round objectForPrimaryKey:@(self.relatedRoundID)];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"ID: %lld, qID: %lld, aID: %lld uID: %lld\nQuestion: %@, Answer: %@ - %@",
                      self.ID, [self relatedQuestion].ID, [self relatedAnswer].ID, [self relatedUser].ID,
                      [self relatedQuestion].text, [self relatedAnswer].text, [self relatedAnswer].isCorrect? @"Correct" : @"Incorrect"];
}

@end
