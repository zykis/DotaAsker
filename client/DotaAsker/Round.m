//
//  Round.m
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "Round.h"

@implementation Round

- (id)init {
    self = [super init];
    if (self) {
        self.questions = [[NSMutableArray alloc] init];
        self.userAnswers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    Round* r = object;
    if (r.ID == self.ID) {
        return YES;
    }
    return NO;
}

//- (id)copyWithZone:(NSZone *)zone {
////    @property (assign, nonatomic) unsigned long long ID;
////    @property (strong, nonatomic) User* nextMoveUser;
////    @property (strong, nonatomic) NSMutableArray* questions;//список вопросов
////    @property (strong, nonatomic) NSMutableArray* userAnswers;//список ответов
//    Round *newRound = [super copyWithZone:zone];
//    newRound.ID = [_month copyWithZone:zone];
//    newCrime->_category = [_category copyWithZone:zone];
//    // etc...
//    return newCrime;
//}

@end
