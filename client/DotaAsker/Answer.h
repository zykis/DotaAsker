//
//  Answer.h
//  DotaAsker
//
//  Created by Artem on 22/09/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Answer : NSObject

@property (assign, nonatomic) unsigned long long ID;
@property (assign, nonatomic) unsigned long long relatedQuestionID;
@property (strong, nonatomic) NSString* text;
@property (assign, nonatomic) BOOL isCorrect;

@end
