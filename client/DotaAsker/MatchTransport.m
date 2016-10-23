//
//  MatchTransport.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "MatchTransport.h"
#import "UserService.h"
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
#import <AFNetworking/AFNetworking/AFNetworking.h>

#define ENDPOINT_FIND_MATCH @"http://127.0.0.1:5000/findMatch"

@implementation MatchTransport

- (RACReplaySubject*) findMatchForUser:(NSString*)accessToken {
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:ENDPOINT_FIND_MATCH parameters:nil error:nil] mutableCopy];
    
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

@end
