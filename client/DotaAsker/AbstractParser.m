//
//  AbstractParser.m
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "AbstractParser.h"

@implementation AbstractParser

- (id)parse:(NSData *)JSONData {
    @throw [NSException exceptionWithName:@"invocation of pure method" reason:nil userInfo:nil];
}

- (NSArray*)parseAll:(NSData *)data {
    @throw [NSException exceptionWithName:@"invocation of pure method" reason:nil userInfo:nil];
}

- (NSData*)encode:(id)entity {
    @throw [NSException exceptionWithName:@"invocation of pure method" reason:nil userInfo:nil];
}

@end
