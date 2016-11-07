//
//  QuestionService.h
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AbstractService.h"
#import "Question.h"

@class QuestionTransport;
@interface QuestionService : AbstractService

@property(strong, nonatomic) QuestionTransport* transport;
- (RACReplaySubject*)obtainImageForQuestion: (Question*)question withWidth: (NSUInteger)width andHeight: (NSUInteger)height;

@end
