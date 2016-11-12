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
#import "UserCache.h"
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
#import "User.h"
#import "AuthorizationService.h"

@implementation UserService

@synthesize transport = _transport;
@synthesize cache = _cache;

- (id)init {
    self = [super init];
    if(self) {
        _cache = [[UserCache alloc] init];
        _transport = [[UserTransport alloc] init];
    }
    return self;
}

- (RACReplaySubject*)obtain:(unsigned long long)ID {
    RACReplaySubject* subject = [[RACReplaySubject alloc] init];
    [[_transport obtain:ID] subscribeNext:^(id x) {
        User* u = [UserParser parse:x andChildren:NO];
        [subject sendNext:u];
    } error:^(NSError *error) {
        [subject sendError:error];
    } completed:^{
        [subject sendCompleted];
    }];
    return subject;
}

- (RACReplaySubject*)obtainWithAccessToken:(NSString *)accessToken {
    RACReplaySubject* subject = [[RACReplaySubject alloc] init];
    [[_transport obtainWithAccessToken:accessToken] subscribeNext:^(id x) {
        User* u = [UserParser parse:x andChildren:YES];
        [subject sendNext:u];
    } error:^(NSError *error) {
        [subject sendError:error];
    } completed:^{
        [subject sendCompleted];
    }];
    return subject;
}

- (RACReplaySubject*)update:(id)entity {
    RACReplaySubject* subject = [[RACReplaySubject alloc] init];
    [[_transport update:entity] subscribeNext:^(id x) {
        User* u = [UserParser parse:x andChildren:YES];
        [subject sendNext:u];
        [subject sendCompleted];
    } error:^(NSError *error) {
        [subject sendError:error];
    } completed:^{
        [subject sendCompleted];
    }];
    return subject;
}

- (RACReplaySubject*)sendFriendRequestToUser:(User *)to_user {
    RACReplaySubject* subject = [RACReplaySubject subject];
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedLongLong:to_user.ID], @"to_id", nil];
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    
    [[_transport sendFriendtoUserData:data withAccessToken:[_authorizationService accessToken]] subscribeNext:^(id x) {
        NSLog(@"Friend request has sent");
        [subject sendNext:x];
        [subject sendCompleted];
    } error:^(NSError *error) {
        [subject sendError:error];
        NSLog(@"Error while senting friend request");
    } completed:^{
        [subject sendCompleted];
    }];
    return subject;
}

@end
