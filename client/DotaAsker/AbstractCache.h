//
//  AbstractCache.h
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AbstractCache : NSObject

@property (strong, nonatomic) NSMutableArray* entities;

- (NSArray*)obtainAll;
- (id)obtain:(unsigned long long) entityID;
- (id)update:(id) entity;
- (void)append:(id)entity;
- (void)appendEntities:(NSArray *)entities;
- (void)remove:(unsigned long long) entityID;

@end
