//
//  PlayerService.m
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "PlayerService.h"
#import "PlayerParser.h"
#import "PlayerTransport.h"

@implementation PlayerService

@synthesize transport;
@synthesize parser;
@synthesize cache;

- (id)init {
    self = [super init];
    if(self) {
        parser = [[PlayerParser alloc] init];
        cache = [[AbstractCache alloc] init];
        transport = [[PlayerTransport alloc] init];
    }
    return self;
}

+ (PlayerService*)instance {
    static PlayerService *playerService = nil;
    @synchronized(self) {
        if(playerService == nil)
            playerService = [[self alloc] init];
    }
    return playerService;
}

- (Player*)obtainPlayerWithUsername:(NSString *)username {
    SEL obtainPlayerWithUsername = NSSelectorFromString(@"obtainPlayerWithUsername:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSData* data = [transport performSelector:obtainPlayerWithUsername withObject:username];
#pragma clang diagnostic pop
    NSError* error;
    if (data) {
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!error) {
            Player* p = [parser parse:jsonDict];
            return p;
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}

@end
