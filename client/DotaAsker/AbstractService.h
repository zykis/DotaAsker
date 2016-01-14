//
//  AbstractService.h
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AbstractCache;
@class AbstractParser;
@class Transport;

@interface AbstractService : NSObject

@property (strong, nonatomic) AbstractParser* parser;
@property (strong, nonatomic) AbstractCache* cache;
@property (strong, nonatomic) Transport* transport;
- (id)obtain:(NSInteger) entityID;
- (NSArray*)obtainAll;
- (void)remove:(NSInteger) entityID;
- (id)update:(id) entity;
- (id)create:(id) entity;

@end
