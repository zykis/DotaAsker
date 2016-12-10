//
//  UserTransport.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "UserTransport.h"
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>
#import <AFNetworking/AFNetworking/AFNetworking.h>

#define ENDPOINT_USER @"http://127.0.0.1:5000/users/"
#define ENDPOINT_USER_UPDATE @"http://127.0.0.1:5000/user"
#define ENDPOINT_PLAYER @"http://127.0.0.1:5000/MainViewController"
#define ENDPOINT_SEND_FRIEND_REQUEST @"http://127.0.0.1:5000/sendFriendRequest"
#define ENDPOINT_TOP100 @"http://127.0.0.1:5000/top100"
#define ENDPOINT_STATISTIC @"http://127.0.0.1:5000/statistic/"

@implementation UserTransport

- (RACReplaySubject*)obtain:(unsigned long long)entityID {
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    NSString* requestString = [NSString stringWithFormat:@"%@%llu", ENDPOINT_USER, entityID];
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:requestString parameters:nil error:nil] mutableCopy];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            [subject sendError:error];
        } else {
            [subject sendNext: responseObject];
            [subject sendCompleted];
        }
    }];
    
    [dataTask resume];
    
    return subject;
}

- (RACReplaySubject*) obtainWithAccessToken:(NSString *)accessToken {
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:ENDPOINT_PLAYER parameters:nil error:nil] mutableCopy];
    
    // Forming string with credentials 'myusername:mypassword'
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", accessToken, @"unused"];
    // Getting data from token
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    // Encoding data with base64 and converting back to NSString
    NSString* authStrData = [[NSString alloc] initWithData:[authData base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed] encoding:NSASCIIStringEncoding];
    // Forming Basic Authorization string Header
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", authStrData];
//    NSLog(@"AuthValue: %@", authValue);
    // Assigning it to request
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            [subject sendError:error];
        } else {
            [subject sendNext: responseObject];
            [subject sendCompleted];
        }
    }];
    [dataTask resume];
    
    return subject;
}

- (RACReplaySubject*)update:(NSData*)entityData {
    RACReplaySubject* subject = [[RACReplaySubject alloc] init];
    
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:ENDPOINT_USER_UPDATE parameters:nil error:nil] mutableCopy];
    [request setHTTPBody:entityData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            [subject sendError:error];
        } else {
            [subject sendNext: responseObject];
            [subject sendCompleted];
        }
    }];
    
    [dataTask resume];
    return subject;
}

- (RACReplaySubject*)obtainStatistic:(unsigned long long)entityID {
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    NSString* requestString = [NSString stringWithFormat:@"%@%llu", ENDPOINT_STATISTIC, entityID];
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:requestString parameters:nil error:nil] mutableCopy];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            [subject sendError:error];
        } else {
            [subject sendNext: responseObject];
            [subject sendCompleted];
        }
    }];
    
    [dataTask resume];
    
    return subject;
}

- (RACReplaySubject*)sendFriendtoUserData:(NSData *)to_user_data withAccessToken:(NSString *)accessToken {
    RACReplaySubject* subject = [RACReplaySubject subject];
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:ENDPOINT_SEND_FRIEND_REQUEST parameters:nil error:nil] mutableCopy];
    
    // Forming string with credentials 'myusername:mypassword'
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", accessToken, @"unused"];
    // Getting data from token
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    // Encoding data with base64 and converting back to NSString
    NSString* authStrData = [[NSString alloc] initWithData:[authData base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed] encoding:NSASCIIStringEncoding];
    // Forming Basic Authorization string Header
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", authStrData];
    // Assigning it to request
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:to_user_data];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            [subject sendError:error];
        } else {
            [subject sendNext: responseObject];
            [subject sendCompleted];
        }
    }];
    [dataTask resume];
    return subject;
}

- (RACReplaySubject*)top100withAccessToken:(NSString *)accessToken {
    RACReplaySubject* subject = [RACReplaySubject subject];
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:ENDPOINT_TOP100 parameters:nil error:nil] mutableCopy];
    
    // Forming string with credentials 'myusername:mypassword'
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", accessToken, @"unused"];
    // Getting data from token
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    // Encoding data with base64 and converting back to NSString
    NSString* authStrData = [[NSString alloc] initWithData:[authData base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed] encoding:NSASCIIStringEncoding];
    // Forming Basic Authorization string Header
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", authStrData];
    // Assigning it to request
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            [subject sendError:error];
        } else {
            [subject sendNext: responseObject];
            [subject sendCompleted];
        }
    }];
    [dataTask resume];
    return subject;
}

@end
