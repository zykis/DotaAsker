//
//  UserParser.h
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AbstractParser.h"

@class User;

@interface UserParser: NSObject

+ (User*)parse:(NSDictionary *)JSONDict andChildren:(BOOL)bParseChildren;

@end
