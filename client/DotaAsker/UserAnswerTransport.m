//
//  UserAnswerTransport.m
//  DotaAsker
//
//  Created by Artem on 17/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "UserAnswerTransport.h"
#import "UserAnswer.h"
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>
#import <AFNetworking/AFNetworking/AFNetworking.h>

#define kAPIEndpointUserAnswer (kAPIEndpointHost @"/userAnswers")

@implementation UserAnswerTransport

- (RACReplaySubject*)create:(id)entityData {
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:kAPIEndpointUserAnswer parameters:nil error:nil] mutableCopy];
    
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

@end
