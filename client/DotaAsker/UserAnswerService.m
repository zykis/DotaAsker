//
//  UserAnswerService.m
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "UserAnswerService.h"
#import "AnswerService.h"
#import "UserAnswer.h"

@implementation UserAnswerService

+ (UserAnswerService*)instance {
    static UserAnswerService *userAnswerService = nil;
    @synchronized(self) {
        if(userAnswerService == nil)
            userAnswerService = [[self alloc] init];
    }
    return userAnswerService;
}

@end
