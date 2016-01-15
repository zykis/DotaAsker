//
//  AnswerService.h
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AbstractService.h"
#import "Answer.h"
#import "Question.h"

@interface AnswerService : AbstractService
+ (AnswerService*)instance;

- (Answer*)answerAtIndex:(NSInteger)index ofQuestion:(Question*)question;
- (Answer*)correctAnswerForQuestion:(Question*)question;
- (NSArray*)answersForQuestion:(Question*)question;

@end
