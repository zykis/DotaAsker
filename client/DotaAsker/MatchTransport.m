//
//  MatchTransport.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "MatchTransport.h"
#import "UserService.h"

@implementation MatchTransport

- (NSData*)findMatch {
    NSString *message = [NSString stringWithFormat: @"{\"COMMAND\":\"FIND_MATCH\", \"PLAYER_NAME\":\"%@\"}", [[[UserService instance] player] name]];
    NSData* JSONData = [[self obtainMessageWithMessage:message] dataUsingEncoding:NSUTF8StringEncoding];
    return JSONData;
}

@end
