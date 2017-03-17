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

@property (strong, nonatomic) UserAnswerTransport* transport;
- (long long)getNextPrimaryKey;

- (NSString*)textForUserAnswerFirst: (UserAnswer*)ua1 andSecond: (UserAnswer*)ua2;
- (void)sendUserAnswers: (NSArray*)unsynchronizedUserAnswers next:(void (^ _Nullable)(UserAnswer* x))nextBlock error:(void (^_Nonnull)(NSError** error))errorBlock complete:(void(^)())completeBlock;

@end
