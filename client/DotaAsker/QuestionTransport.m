//
//  QuestionTransport.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "QuestionTransport.h"
#import "Question.h"
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
#import <AFNetworking/AFNetworking/AFNetworking.h>
#define CLOUDINARY_API_KEY 13
#define CLOUDINARY_API_SECRET 13
#define CLOUDINARY_ENDPOINT @"http://res.cloudinary.com"
#define CLOUDINARY_NAME @"dzixpee1a"

@implementation QuestionTransport

- (RACReplaySubject*)obtainImageForQuestion:(Question *)question withWidth:(NSUInteger)width andHeight:(NSUInteger)height {
    RACReplaySubject* subject = [[RACReplaySubject alloc] init];
    NSString* urlString = [NSString stringWithFormat:@"%@/%@/image/upload/c_scale,h_%lu,w_%lu/v1478341442/%@",
                           CLOUDINARY_ENDPOINT,
                           CLOUDINARY_NAME,
                           height,
                           width,
                           [question imageName]];
    
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:urlString parameters:nil error:nil] mutableCopy];
    
    // [request setHTTPBody:entityData];
     [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    
    // AFImageResponseSerializer
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    [manager setResponseSerializer:[AFImageResponseSerializer serializer]];
    
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
