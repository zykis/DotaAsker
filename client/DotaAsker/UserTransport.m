//
//  UserTransport.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "UserTransport.h"

@implementation UserTransport

- (NSData*)obtainUserWithUsername:(NSString *)username {
    NSString *message = [NSString stringWithFormat:@"{\"COMMAND\":\"GET_USER_BY_USERNAME\", \"USERNAME\":\"%@\"}", username];
    NSData* JSONData = [[self obtainMessageWithMessage:message] dataUsingEncoding:NSUTF8StringEncoding];
    return JSONData;
}

@end
