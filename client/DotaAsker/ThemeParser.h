//
//  ThemeParser.h
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AbstractParser.h"

@class Theme;

@interface ThemeParser : AbstractParser

+ (Theme*)parse: (NSDictionary*)JSONDict;

@end
