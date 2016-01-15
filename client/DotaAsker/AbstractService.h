//
//  AbstractService.h
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractCache.h"
#import "AbstractParser.h"
#import "Transport.h"

@interface AbstractService : NSObject

@property (strong, nonatomic) AbstractParser* parser;
@property (strong, nonatomic) AbstractCache* cache;
@property (strong, nonatomic) Transport* transport;

- (id)obtain:(unsigned long long) entityID;
- (NSArray*)obtainAll;
- (void)remove:(unsigned long long) entityID;
- (id)update:(id) entity;
- (id)create:(id) entity;

@end
