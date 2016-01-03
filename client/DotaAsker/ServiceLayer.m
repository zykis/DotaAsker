//
//  ServiceLayer.m
//  DotaAsker
//
//  Created by Artem on 21/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "ServiceLayer.h"
#import "UserAnswerService.h"

@implementation ServiceLayer

@synthesize userAnswerService;

-(id)init {
    self = [super init];
    if(self) {
        userAnswerService = [[UserAnswerService alloc] init];
    }
    return self;
}

@end
