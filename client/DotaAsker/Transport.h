//
//  Transport.h
//  DotaAsker
//
//  Created by Artem on 17/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking/AFNetworking.h"
#import "AFNetworking/AFURLResponseSerialization.h"

@interface Transport : NSObject

- (NSData*)obtain:(unsigned long long) entityID;
- (NSData*)obtainAll;
- (NSData*)update:(NSData*) entity;
- (NSData*)create:(NSData*) entity;
- (void)remove:(unsigned long long) entityID;

@end
