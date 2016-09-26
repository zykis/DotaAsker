//
//  MatchParser.h
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AbstractParser.h"

@class Match;

@interface MatchParser : NSObject

+ (Match*)parse: (NSDictionary*)JSONDict andChildren:(BOOL)bParseChildren;

@end
