//
//  QuestionTransport.h
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "Transport.h"

@class RACReplaySubject;
@class Question;
@interface QuestionTransport : Transport

- (RACReplaySubject*)obtainImageForQuestion: (Question*)question withWidth: (NSUInteger)width andHeight: (NSUInteger)height;
- (RACReplaySubject*)submitQuestionData: (NSData*)questionData;

@end
