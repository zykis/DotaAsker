//
//  QuestionParser.h
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AbstractParser.h"

@class Question;

@interface QuestionParser : NSObject

+ (Question*)parse: (NSDictionary*)JSONDict;

@end
