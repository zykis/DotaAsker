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

@synthesize authorizationService = _authorizationService;
@synthesize userAnswerService;
@synthesize answerService;
@synthesize questionService;
@synthesize themeService;
@synthesize roundService = _roundService;
@synthesize matchService = _matchService;
@synthesize userService = _userService;

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
        _authorizationService = [[AuthorizationService alloc] init];
        _userService = [[UserService alloc] init];
        _matchService = [[MatchService alloc] init];
        _roundService = [[RoundService alloc] init];
        [_userService setAuthorizationService:_authorizationService];
    }
    return self;
}

@end
