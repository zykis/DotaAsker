//
//  AnswerParser.h
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AbstractParser.h"

@class Answer;

@interface AnswerParser : NSObject

+ (Answer*)parse: (NSDictionary*) JSONDict;

@end
