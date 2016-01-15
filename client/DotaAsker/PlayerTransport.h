//
//  PlayerTransport.h
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "Transport.h"

@interface PlayerTransport : Transport

- (NSData*)obtainPlayerWithUsername:(NSString*)username;

@end
