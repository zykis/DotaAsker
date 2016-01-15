//
//  Answer.h
//  DotaAsker
//
//  Created by Artem on 02/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAnswer: NSObject

@property (assign, nonatomic) unsigned long long ID;
@property (assign, nonatomic) unsigned long long relatedQuestionID;
@property (assign, nonatomic) unsigned long long relatedAnswerID;
@property (assign, nonatomic) unsigned long long relatedRoundID;
@property (assign, nonatomic) unsigned long long relatedUserID;
    
@end
