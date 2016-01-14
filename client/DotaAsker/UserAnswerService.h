//
//  UserAnswerService.h
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "UserAnswer.h"
#import "AbstractService.h"
#import "UserAnswerTransport.h"
#import "UserAnswerParser.h"
#import "UserAnswerCache.h"

#import "Round.h"
#import "User.h"

@interface UserAnswerService : AbstractService

- (UserAnswer*)userAnswerAtIndex:(NSInteger)index ofUser:(User*)user ofRound:(Round*)round;
- (NSString*)textForUserAnswer:(UserAnswer*)userAnswer;

@property (strong, nonatomic) UserAnswerParser* parser;
@property (strong, nonatomic) UserAnswerCache* cache;
@property (strong, nonatomic) UserAnswerTransport* transport;

@end
