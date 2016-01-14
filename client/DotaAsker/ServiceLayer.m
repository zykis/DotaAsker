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

+ (ServiceLayer*)instance {
    static ServiceLayer *serviceLayer = nil;
    @synchronized(self) {
        if(serviceLayer == nil)
            serviceLayer = [[self alloc] init];
    }
    return serviceLayer;
}

-(id)init {
    self = [super init];
    if(self) {
        userAnswerService = [[UserAnswerService alloc] init];
    }
    return self;
}

@end
