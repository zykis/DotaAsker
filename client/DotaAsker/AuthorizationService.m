//
//  AuthorizationService.m
//  DotaAsker
//
//  Created by Artem on 21/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "AuthorizationService.h"

@implementation AuthorizationService

@synthesize transport;

- (BOOL)authWithLogin:(NSString *)login andPassword:(NSString *)password errorString:(NSString**)errorStr {
    NSString* authMessage = [NSString stringWithFormat:@"{\"COMMAND\":\"SIGNIN\", \"LOGIN\":\"%@\", \"PASSWORD\":\"%@\"}", login, password];
    NSString* res = [transport obtainMessageWithMessage:authMessage];
    NSError* err;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[res dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
    if (!err) {
        if ([[dict objectForKey:@"RESULT"] isEqualToString: @"SUCCEED"]) {
            return YES;
        }
        else {
            *errorStr = [dict objectForKey:@"REASON"];
            return NO;
        }
    }
    else {
        *errorStr = [dict objectForKey:@"REASON"];
        return NO;
    }
}

@end
