//
//  UserAnswerParser.h
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "AbstractParser.h"
@class UserAnswer;

@interface UserAnswerParser : NSObject

+ (UserAnswer*)parse: (NSDictionary*) JSONDict;
+ (NSData*)encode: (UserAnswer*)userAnswer;

@end
