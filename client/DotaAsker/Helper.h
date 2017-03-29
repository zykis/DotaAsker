//
//  APIHelper.h
//  DotaAsker
//
//  Created by Artem on 23/09/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthorizationService.h"
@import CoreGraphics;

@class RACReplaySubject;
@class Player;

@interface Helper : NSObject

+ (Helper*)shared;
- (CGSize)getQuestionImageViewSize;
- (RACReplaySubject*)sendNewPasswordToUserOrEmail:(NSString*)userOrEmail;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

@end
