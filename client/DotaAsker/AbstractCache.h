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

- (NSArray*)allEntities;
- (void)append: (id)entity;

@end
