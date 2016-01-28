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

@synthesize authorizationService;
@synthesize userAnswerService;
@synthesize answerService;
@synthesize questionService;
@synthesize themeService;
@synthesize roundService;
@synthesize matchService;
@synthesize userService;

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
        authorizationService = [AuthorizationService instance];
        userAnswerService = [UserAnswerService instance];
        answerService = [AnswerService instance];
        questionService = [QuestionService instance];
        themeService = [ThemeService instance];
        roundService = [RoundService instance];
        matchService = [MatchService instance];
        userService = [UserService instance];
    }
    return self;
}

@end
