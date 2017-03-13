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
    
    if (correctAnswer.text) {
        if ((firstUserAnswerText) && (secondUserAnswerText))
            text = [NSString stringWithFormat:
                    @"%@\n\n"
                    "%@: %@\n"
                    "%@: %@\n"
                    "Right: %@"
                    , question.text,
                    [firstUser name],
                    firstUserAnswerText,
                    [opponent name],
                    secondUserAnswerText,
                    correctAnswer.text
                    ];
        else if ((firstUserAnswerText) && (!secondUserAnswerText))
            text = [NSString stringWithFormat:
                    @"%@\n\n"
                    "%@: %@\n"
                    "Right: %@"
                    , relatedQuestion.text,
                    [player name],
                    firstUserAnswerText,
                    correctAnswer.text
                    ];
        else if ((!firstUserAnswerText) && (secondUserAnswerText))
            text = [NSString stringWithFormat:
                    @"%@\n\n"
                    "%@: %@\n"
                    , relatedQuestion.text,
                    [opponent name],
                    @"???"
                    ];
        else
            text = [NSString stringWithFormat:
                    @"%@\n\n"
                    "%@: %@\n"
                    , relatedQuestion.text,
                    [player name],
                    @"Unanswered"
                    ];
    }
    return text;
}

@end
