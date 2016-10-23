//
//  APIHelper.m
//  DotaAsker
//
//  Created by Artem on 23/09/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#define ENDPOINT_A @"https://api.foursquare.com/v2/venues/explore"

#define ENDPOINT_MAIN_VIEW_CONTROLLER @"http://127.0.0.1:5000/MainViewController"

#import "APIHelper.h"
#import "EndpointParser.h"
#import "AFNetworking/AFNetworking/AFNetworking.h"
#import "AFNetworking/AFNetworking/AFURLResponseSerialization.h"
#import "ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h"
#import "AuthorizationService.h"
#import "Player.h"
#import "UserParser.h"

@implementation APIHelper

/*
 Singleton instance to have an opportunity of early initialization
 of cache sizes and setting up current location
 */
+ (APIHelper*)shared {
    static APIHelper* instance = nil;
    @synchronized (self) {
        if (instance == nil) {
            instance = [[APIHelper alloc] init];
        }
    }
    return instance;
}

- (id)init {
    self = [super init];
    if(self) {
        //settting cache capacity
        NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                             diskCapacity:20 * 1024 * 1024
                                                                 diskPath:nil];
        [NSURLCache setSharedURLCache:URLCache];
    }
    return self;
}

- (RACReplaySubject*)getPlayerWithToken:(NSString *)accessToken {
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:ENDPOINT_MAIN_VIEW_CONTROLLER parameters:nil error:nil] mutableCopy];
    
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
            //parse result
            User* player = [UserParser parse:responseObject andChildren:YES];
            if(player) {
                [subject sendNext: player];
                [subject sendCompleted];
            }
            else {
                [subject sendError:nil];
            }
        }
    }];
        
    [dataTask resume];
    
    return subject;
}

@end

