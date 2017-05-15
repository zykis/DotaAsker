//
//  AuthorizationService.m
//  DotaAsker
//
//  Created by Artem on 21/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//
#import "Transport.h"

#define ENDPOINT_A (kAPIEndpointHost @"/users")
#define ENDPOINT_B (kAPIEndpointHost @"/token")
#define ENDPOINT_C (kAPIEndpointHost @"/login")

#import "AuthorizationService.h"
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>
#import <AFNetworking/AFNetworking/AFNetworking.h>

@implementation AuthorizationService

- (id)init
{
    self = [super init];
    return self;
}

- (RACSubject*)signUpWithLogin:(NSString *)login andPassword:(NSString *)password email:(NSString *)email
{
    RACReplaySubject *subject = [RACReplaySubject subject];

    NSMutableURLRequest* request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:ENDPOINT_A parameters:nil error:nil] mutableCopy];
    
    NSMutableDictionary* dict = [[NSDictionary dictionaryWithObjectsAndKeys:login, @"username", password, @"password", nil] mutableCopy];
    if (![email isEqualToString:@""]) {
        [dict setValue:email forKey:@"email"];
    }

    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSMutableDictionary* errDict = [(NSDictionary*)responseObject mutableCopy];
            NSString* errorDescription = [errDict valueForKey:@"message"];
            [errDict setObject:errorDescription forKey:NSLocalizedDescriptionKey];
            
            NSError* err = [NSError errorWithDomain:error.domain code:error.code userInfo:errDict];
            [subject sendError:err];
        } else {
            [subject sendNext:responseObject];
            [subject sendCompleted];
        }
    }];
    [dataTask resume];
    return subject;
}

- (NSString *)formatURLRequest:(NSURLRequest *)request
{
    NSMutableString *message = [NSMutableString stringWithString:@"---REQUEST------------------\n"];
    [message appendFormat:@"URL: %@\n",[request.URL description] ];
    [message appendFormat:@"METHOD: %@\n",[request HTTPMethod]];
    for (NSString *header in [request allHTTPHeaderFields])
    {
        [message appendFormat:@"%@: %@\n",header,[request valueForHTTPHeaderField:header]];
    }
    [message appendFormat:@"BODY: %@\n",[[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]];
    [message appendString:@"----------------------------\n"];
    return [NSString stringWithFormat:@"%@",message];
}

- (RACReplaySubject*)getTokenForUsername:(NSString *)username andPassword:(NSString *)password
{
    RACReplaySubject* subject = [RACReplaySubject subject];
    NSMutableURLRequest* request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:ENDPOINT_B parameters:nil error:nil] mutableCopy];
    
    // Forming string with credentials 'myusername:mypassword'
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", username, password];
    // Getting data from it
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    // Encoding data with base64 and converting back to NSString
    NSString* authStrData = [[NSString alloc] initWithData:[authData base64EncodedDataWithOptions:NSDataBase64Encoding76CharacterLineLength] encoding:NSASCIIStringEncoding];
    // Forming Basic Authorization string Header
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", authStrData];
    // Assigning it to request
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request
                                                completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (responseObject != nil) {
                NSString* errorString = NSLocalizedString([responseObject valueForKey:@"message"], 0);
                NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil];
                NSError* err = [NSError errorWithDomain:NSURLErrorDomain code:error.code userInfo:dict];
                [subject sendError:err];
            }
            else if (([error code] == -1004) || ([error code] == -1011)) {
                // -1004 nginx unavailable
                // -1011 dotaasker internal server unavailable
                NSString* errorString = NSLocalizedString(@"Unable to connect to server", 0);
                NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil];
                NSError* err = [NSError errorWithDomain:NSURLErrorDomain code:error.code userInfo:dict];
                [subject sendError:err];
            }
            else {
                [subject sendError:error];
            }
        } else {
            NSDictionary* rv = (NSDictionary*)responseObject;
            NSString* token = [rv valueForKey:@"token"];
            
            [subject sendNext:token];
            [subject sendCompleted];
        }
    }];
    [dataTask resume];
    return subject;
}

@end
