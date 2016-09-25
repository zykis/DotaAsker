//
//  APIHelper.h
//  DotaAsker
//
//  Created by Artem on 23/09/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthorizationService.h"
@class RACReplaySubject;
@class Player;

@interface APIHelper : NSObject

@property (strong, nonatomic) NSArray* categories;

+ (APIHelper*)shared;
- (RACReplaySubject*)getPlayerWithToken: (NSString*)accessToken;
@end
