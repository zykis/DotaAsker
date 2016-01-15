//
//  PlayerTransport.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "PlayerTransport.h"

@implementation PlayerTransport

- (NSData*)obtainPlayerWithUsername:(NSString *)username {
    NSString *message = [NSString stringWithFormat:@"{\"COMMAND\":\"GET\", \"ENTITY\":\"%@\", \"USERNAME\":\"%@\"}", @"PLAYER", username];
    NSData* JSONData = [[self obtainMessageWithMessage:message] dataUsingEncoding:NSUTF8StringEncoding];
    return JSONData;
}

@end
