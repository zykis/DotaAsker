//
//  AuthorizationService.m
//  DotaAsker
//
//  Created by Artem on 21/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//
#define ENDPOINT_A @"http://127.0.0.1:5000/users"
#define ENDPOINT_B @"http://127.0.0.1:5000/token"
#define ENDPOINT_C @"http://127.0.0.1:5000/login"

#import "AuthorizationService.h"
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
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
    
    NSData* jsonData= [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    
    NSString* jsonString = [NSString stringWithUTF8String:[jsonData bytes]];
    NSString* lengthStr = [NSString stringWithFormat:@"%ld", [jsonString length]];

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:lengthStr forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
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
    NSLog(@"AuthValue: %@", authValue);
    // Assigning it to request
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request
                                                completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSMutableDictionary* errDict = [(NSDictionary*)responseObject mutableCopy];
            NSString* errorDescription = [errDict valueForKey:@"message"];
            [errDict setObject:errorDescription forKey:NSLocalizedDescriptionKey];
            
            NSError* err = [NSError errorWithDomain:error.domain code:error.code userInfo:errDict];
            [subject sendError:err];
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
