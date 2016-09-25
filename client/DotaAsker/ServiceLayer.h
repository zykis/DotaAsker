//
//  ServiceLayer.h
//  DotaAsker
//
//  Created by Artem on 21/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthorizationService.h"
#import "UserAnswerService.h"
#import "AnswerService.h"
#import "QuestionService.h"
#import "ThemeService.h"
#import "RoundService.h"
#import "MatchService.h"
#import "UserService.h"

@interface ServiceLayer : NSObject

+ (ServiceLayer*)instance;

@property (strong, nonatomic) AuthorizationService* authorizationService;
@property (strong, nonatomic) UserAnswerService* userAnswerService;
@property (strong, nonatomic) AnswerService* answerService;
@property (strong, nonatomic) QuestionService* questionService;
@property (strong, nonatomic) ThemeService* themeService;
@property (strong, nonatomic) RoundService* roundService;
//@property (strong, nonatomic) MatchService* matchService;
@property (strong, nonatomic) UserService* userService;


@end
