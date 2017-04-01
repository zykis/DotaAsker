//
//  RoundTransport.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

// Local
#import "RoundTransport.h"
#import "Helper.h"

// Libraries
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>
#import <AFNetworking/AFNetworking/AFNetworking.h>

#define kAPIEndpointRound (kAPIEndpointHost @"/rounds")

@implementation RoundTransport

- (RACReplaySubject*)update:(NSData *)entityData {
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:kAPIEndpointRound parameters:nil error:nil] mutableCopy];
    
    [request setHTTPBody:entityData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[Helper currentLocale] forHTTPHeaderField:@"Accept-Language"];
    
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

@end
