//
//  UserService.m
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "UserService.h"
#import "UserParser.h"
#import "UserTransport.h"
#import "MatchService.h"

@implementation UserService

@synthesize transport;
@synthesize parser;
@synthesize cache;
@synthesize player = _player;

- (id)init {
    self = [super init];
    if(self) {
        parser = [[UserParser alloc] init];
        cache = [[AbstractCache alloc] init];
        transport = [[UserTransport alloc] init];
    }
    return self;
}

+ (UserService*)instance {
    static UserService *userService = nil;
    @synchronized(self) {
        if(userService == nil)
            userService = [[self alloc] init];
    }
    return userService;
}

- (UIImage*)wallpapersDefault {
    UIImage* wp = [UIImage imageNamed:@"wallpaper_default.jpg"];
    return wp;
}

- (UIImage*)avatarForUser:(User *)user {
    UIImage* avatar = [UIImage imageNamed:[user avatarImageName]];
    return avatar;
}

- (User*)obtainUserWithUsername:(NSString *)username {
    SEL obtainUserWithUsername = NSSelectorFromString(@"obtainUserWithUsername:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSData* data = [transport performSelector:obtainUserWithUsername withObject:username];
#pragma clang diagnostic pop
    if (!data) {
        return nil;
    }
    NSError* error;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (!error) {
        User* u = [parser parse:jsonDict];
        return u;
    }
    else {
        return nil;
    }
}

- (User*)opponentForMatch:(Match *)match {
    unsigned long long userID = [match opponentID];
    User* u = [self obtain:userID];
    return u;
}

- (User*)playerForMatch:(Match *)match {
    unsigned long long userID = [match playerID];
    User* u = [self obtain:userID];
    return u;
}

- (User*)opponentForRound:(Round *)round {
    User* u;
    Match* m = [[MatchService instance] matchForRound:round];
    if (m) {
        unsigned long long userID = [m opponentID];
        u = [self obtain:userID];
        return u;
    }
    return nil;
}

- (User*)playerForRound:(Round *)round {
    User* u;
    Match* m = [[MatchService instance] matchForRound:round];
    if (m) {
        unsigned long long userID = [m playerID];
        u = [self obtain:userID];
        return u;
    }
    return nil;
}

@end
