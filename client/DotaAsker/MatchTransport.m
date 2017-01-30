//
//  MatchTransport.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "MatchTransport.h"
#import "UserService.h"
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>
#import <AFNetworking/AFNetworking/AFNetworking.h>

#define kAPIEndpointFindMatch (kAPIEndpointHost @"/findMatch")
#define kAPIEndpointMatch (kAPIEndpointHost @"/matches")
#define kAPIEndpointFinishMatch (kAPIEndpointHost @"/finishMatch")
#define kAPIEndpointSurrend (kAPIEndpointHost @"/surrend")


@implementation MatchTransport

- (RACReplaySubject*) findMatchForUser:(NSString*)accessToken {
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:kAPIEndpointFindMatch parameters:nil error:nil] mutableCopy];
    
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

- (RACReplaySubject*)update:(NSData *)entityData {
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:kAPIEndpointMatch parameters:nil error:nil] mutableCopy];
    
    [request setHTTPBody:entityData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    
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

- (RACReplaySubject*)finishMatch:(NSData *)entityData {
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:kAPIEndpointFinishMatch parameters:nil error:nil] mutableCopy];
    
    [request setHTTPBody:entityData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    
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

- (RACReplaySubject*) surrendAtMatchData:(NSData *)matchData andAccessToken:(NSString *)accessToken {
    RACReplaySubject* subject = [RACReplaySubject subject];
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:kAPIEndpointSurrend parameters:nil error:nil] mutableCopy];
    
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
    [request setHTTPBody:matchData];
    
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
