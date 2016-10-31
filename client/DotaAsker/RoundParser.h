//
//  RoundParser.h
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AbstractParser.h"

@class Round;

@interface RoundParser : NSObject

+ (Round*)parse: (NSDictionary*)JSONDict andChildren:(BOOL)bParseChildren;
+ (NSDictionary*)encode:(Round*)round;

@end
