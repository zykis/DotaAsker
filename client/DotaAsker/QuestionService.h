//
//  QuestionService.h
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AbstractService.h"
#import "Question.h"
#import "Theme.h"
#import "Answer.h"
#import "Round.h"

@interface QuestionService : AbstractService
+ (QuestionService*)instance;

- (NSArray*)generateQuestionsOnTheme:(Theme*)theme;
- (NSArray*)allQuestionsOnTheme:(Theme*)theme;
- (UIImage*)imageOfQuestion:(Question*)question;
- (Question*)questionAtIndex:(NSInteger)index ofRound:(Round*)round;

@end
