//
//  UserAnswerService.h
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "UserAnswer.h"
#import "AbstractService.h"
#import "UserAnswerTransport.h"
#import "UserAnswerParser.h"
#import "UserAnswerCache.h"

#import "Round.h"
#import "User.h"
#import "Question.h"
#import "Answer.h"

@interface UserAnswerService : AbstractService
+ (UserAnswerService*)instance;

- (NSString*)textForUserAnswer:(UserAnswer*)userAnswer;
- (BOOL)isCorrect:(UserAnswer*)userAnswer;

@end
