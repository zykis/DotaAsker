//
//  APIHelper.m
//  DotaAsker
//
//  Created by Artem on 23/09/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "Helper.h"
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>
#import <AFNetworking/AFNetworking/AFNetworking.h>

#define ENDPOINT_FORGOT_PASSWORD @"http://127.0.0.1:5000/forgotPassword"

@implementation Helper
/*
 Singleton instance to have an opportunity of early initialization
 of cache sizes and setting up current location
 */
+ (Helper*)shared {
    static Helper* instance = nil;
    @synchronized (self) {
        if (instance == nil) {
            instance = [[Helper alloc] init];
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

- (CGSize)getQuestionImageViewSize {
    return CGSizeMake(351, 197);
}

- (RACReplaySubject*)sendNewPasswordToUserOrEmail:(NSString *)userOrEmail {
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:ENDPOINT_FORGOT_PASSWORD parameters:nil error:nil] mutableCopy];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys: userOrEmail, @"username_or_email", nil];
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    [request setHTTPBody:data];
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

+ (UIImage*)imageWithImage:(UIImage*)image 
               scaledToSize:(CGSize)newSize;
{
   UIGraphicsBeginImageContext( newSize );
   [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
   UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();

   return newImage;
}

+ (NSString*)currentLocale {
    return [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0]
}

@end

