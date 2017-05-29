//
//  UserAnswerService.m
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "UserAnswerService.h"
#import "AnswerService.h"
#import "UserAnswerParser.h"
#import "UserAnswer.h"
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>
#import "UserAnswerTransport.h"
#import "UserAnswerParser.h"
#import "User.h"

@implementation UserAnswerService

- (id)init {
    self = [super init];
    if (self) {
        _transport = [[UserAnswerTransport alloc] init];
    }
    return self;
}

- (RACReplaySubject*)create:(id)entity {
    RACReplaySubject* subject = [[RACReplaySubject alloc] init];
    NSData* uaData = [UserAnswerParser encode:entity];
    assert(uaData);
    [[_transport create:uaData] subscribeNext:^(id x) {
        UserAnswer* ua = [UserAnswerParser parse:x];
        [subject sendNext:ua];
    } error:^(NSError *error) {
        [subject sendError:error];
    } completed:^{
        [subject sendCompleted];
    }];
    return subject;
}

- (long long)getNextPrimaryKey {
    long long ID = [[[UserAnswer allObjects] maxOfProperty:@"ID"] longLongValue] + 1;
    return ID;
}

- (NSString*)textForUserAnswerFirst: (UserAnswer*)ua1 andSecond: (UserAnswer*)ua2 {
    User* firstUser;
    User* secondUser;
    NSString* firstUserAnswerText;
    NSString* secondUserAnswerText;
    Question* question;
    NSString* text;
    
    if (ua1 != nil) {
        firstUser = [ua1 relatedUser];
        firstUserAnswerText = [[ua1 relatedAnswer] text];
        question = [ua1 relatedQuestion];
    }
    if (ua2 != nil) {
        secondUser = [ua2 relatedUser];
        secondUserAnswerText = [[ua2 relatedAnswer] text];
        question = [ua2 relatedQuestion];
    }
    
    Answer* correctAnswer;
    for (Answer* a in [question answers]) {
        if ([a isCorrect]) {
            correctAnswer = a;
        }
    }
    assert(correctAnswer);
    
    // 3 cases:
    // [1] Player answered, opponent - not
    // [2] Player answered, opponent - too
    // [3] Player didn't answer, opponent - answered
    NSString* rightString = NSLocalizedString(@"Right", 0);
    
    if (correctAnswer.text) {
        if ((firstUserAnswerText) && (secondUserAnswerText))
            text = [NSString stringWithFormat:
                    @"%@\n\n"
                    "%@: %@\n"
                    "%@: %@\n"
                    "%@: %@",
                    question.text,
                    firstUser.name,
                    firstUserAnswerText,
                    secondUser.name,
                    secondUserAnswerText,
                    rightString,
                    correctAnswer.text
                    ];
        else if ((firstUserAnswerText) && (!secondUserAnswerText))
            text = [NSString stringWithFormat:
                    @"%@\n\n"
                    "%@: %@\n"
                    "%@: %@",
                    question.text,
                    firstUser.name,
                    firstUserAnswerText,
                    rightString,
                    correctAnswer.text
                    ];
        else if ((!firstUserAnswerText) && (secondUserAnswerText))
            text = [NSString stringWithFormat:
                    @"%@\n\n"
                    "%@: %@\n",
                    question.text,
                    secondUser.name,
                    secondUserAnswerText
                    ];
        else
            text = [NSString stringWithFormat:
                    @"%@\n\n"
                    "%@: %@\n",
                    question.text,
                    firstUser.name,
                    NSLocalizedString(@"Unanswered", 0)
                    ];
    }
    return text;
}

- (void)sendUserAnswersWithNext:(void (^)(UserAnswer* x))nextBlock error:(void (^)(NSError* error))errorBlock complete:(void(^)())completeBlock {
    dispatch_time_t timeoutTime = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __block BOOL obtained = NO;
        RLMResults<UserAnswer*>* modifiedUserAnswers = [UserAnswer objectsWhere:@"modified == YES"];
        for (UserAnswer* ua in modifiedUserAnswers) {
            // Create UA
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            RACSignal* sig = [self create:ua];
            [sig subscribeNext:^(id  _Nullable x) {
                nextBlock(x);
                obtained = YES;
                } error:^(NSError * _Nullable error) {
                    if ([error code] == 410) {
                        NSLog(@"No userAnswer %@ found in server", [ua description]);
                        obtained = YES;
                    }
                    dispatch_semaphore_signal(semaphore);
                } completed:^{
                    dispatch_semaphore_signal(semaphore);
                }];
            if (dispatch_semaphore_wait(semaphore, timeoutTime)) {
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The operation timed out.", nil),
                    NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Have you tried turning it off and on again?", nil)
                };
                NSError *error = [NSError errorWithDomain:@"com.zykis.dotaasker"
                                                    code:-57
                                                userInfo:userInfo];
                errorBlock(error);
                return;
            }
            if (!obtained) {
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The operation timed out.", nil),
                    NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Have you tried turning it off and on again?", nil)
                };
                NSError *error = [NSError errorWithDomain:@"com.zykis.dotaasker"
                                                    code:-58
                                                userInfo:userInfo];
                errorBlock(error);
                return;
            }
            obtained = NO;
        }
        
        completeBlock();
    });
}

@end
