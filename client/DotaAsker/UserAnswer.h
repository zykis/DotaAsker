//
//  Answer.h
//  DotaAsker
//
//  Created by Artem on 02/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAnswer: NSObject

@property (assign, nonatomic) NSInteger ID;
@property (assign, nonatomic) NSInteger relatedQuestionID;
@property (assign, nonatomic) NSInteger relatedAnswerID;
@property (assign, nonatomic) NSInteger relatedRoundID;
@property (assign, nonatomic) NSInteger relatedUserID;
    
@end
