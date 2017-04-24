//
//  UserAnswerService.h
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "UserAnswer.h"
#import "AbstractService.h"

@class UserAnswerTransport;
@interface UserAnswerService : AbstractService

@property (strong, nonatomic) UserAnswerTransport* _Nullable transport;
- (long long)getNextPrimaryKey;

- (NSString* _Nullable)textForUserAnswerFirst: (UserAnswer*_Nullable)ua1 andSecond: (UserAnswer*_Nullable)ua2;
- (void)sendUserAnswersWithNext:(void (^_Nullable)(UserAnswer* _Nullable x))nextBlock error:(void (^_Nullable)(NSError* _Nullable error))errorBlock complete:(void(^_Nullable)())completeBlock;

@end
