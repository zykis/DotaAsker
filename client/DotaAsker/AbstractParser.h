//
//  AbstractParser.h
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AbstractParser : NSObject

+ (NSArray*)parseAll:(NSData*) data;

@end
