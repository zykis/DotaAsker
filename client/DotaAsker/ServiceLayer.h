//
//  ServiceLayer.h
//  DotaAsker
//
//  Created by Artem on 21/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AuthorizationService;
#import "UserAnswerService.h"
@class AnswerService;
@class QuestionService;
@class ThemeService;
@class RoundService;
@class MatchService;
@class UserService;
@class PlayerService;

@interface ServiceLayer : NSObject

@property (strong, nonatomic) AuthorizationService* authorizationService;
@property (strong, nonatomic) UserAnswerService* userAnswerService;
@property (strong, nonatomic) AnswerService* answerService;
@property (strong, nonatomic) QuestionService* questionService;
@property (strong, nonatomic) ThemeService* themeService;
@property (strong, nonatomic) RoundService* roundService;
@property (strong, nonatomic) MatchService* matchService;
@property (strong, nonatomic) UserService* userService;
@property (strong, nonatomic) PlayerService* playerService;


@end
