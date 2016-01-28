//
//  AuthorizationService.m
//  DotaAsker
//
//  Created by Artem on 21/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "AuthorizationService.h"
#import "AbstractParser.h"
#import "AbstractCache.h"
#import "UserService.h"

@implementation AuthorizationService

@synthesize transport;
@synthesize parser;
@synthesize cache;

- (id)init {
    self = [super init];
    if(self) {
        parser = [[AbstractParser alloc] init];
        cache = [[AbstractCache alloc] init];
        transport = [[Transport alloc] init];
    }
    return self;
}

+ (AuthorizationService*)instance {
    static AuthorizationService *authorizationService = nil;
    @synchronized(self) {
        if(authorizationService == nil)
            authorizationService = [[self alloc] init];
    }
    return authorizationService;
}

- (BOOL)authWithLogin:(NSString *)login andPassword:(NSString *)password errorString:(NSString**)errorStr {
    NSString* authMessage = [NSString stringWithFormat:@"{\"COMMAND\":\"SIGNIN\", \"USERNAME\":\"%@\", \"PASSWORD\":\"%@\"}", login, password];
    NSString* res = [transport obtainMessageWithMessage:authMessage];
    if (!res) {
        *errorStr = [NSString stringWithFormat:@"Server not answering"];
        return NO;
    }
    NSError* err;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[res dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
    if (!err) {
        if ([[dict objectForKey:@"RESULT"] isEqualToString: @"SUCCEED"]) {
            User* user = [[UserService instance] obtainUserWithUsername:login];
            [[UserService instance] setPlayer:user];
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

- (BOOL)signUpWithLogin:(NSString *)login andPassword:(NSString *)password email:(NSString *)email errorString:(NSString *__autoreleasing *)errorStr {
    NSString* authMessage = [NSString stringWithFormat:@"{\"COMMAND\":\"SIGNUP\", \"USERNAME\":\"%@\", \"PASSWORD\":\"%@\", \"EMAIL\":\"%@\"}", login, password, email];
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

- (BOOL)fitsUsername:(NSString *)username andPassword:(NSString *)password error:(NSString *__autoreleasing *)error {
    if ([username length] <= 3) {
        *error = [NSString stringWithFormat:@"Username is incorrect. Should be 3 symblos at least."];
        return NO;
    }
    else if ([password isEqualToString:@""]) {
        *error = [NSString stringWithFormat:@"Password is incorrect. Shouldn't be empty."];
        return NO;
    }
    return YES;
}

@end
