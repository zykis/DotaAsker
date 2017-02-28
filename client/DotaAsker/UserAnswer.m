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

- (id)init {
    self = [super init];
    if (self) {
        self.synchronized = YES;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isMemberOfClass:[UserAnswer class]]) {
        UserAnswer* ua = object;
        return ([ua.relatedUser isEqual:self.relatedUser] && [ua.relatedRound isEqual:self.relatedRound] && [ua.relatedQuestion isEqual:self.relatedQuestion]);
    }
    return NO;
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

@end
