//
//  MatchTransport.h
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "Transport.h"
#import "Match.h"

@interface MatchTransport : Transport

- (NSData*)findMatch;

@end
