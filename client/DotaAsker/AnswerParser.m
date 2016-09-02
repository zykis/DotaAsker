//
//  AnswerParser.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AnswerParser.h"
#import "Answer.h"

@implementation AnswerParser

- (Answer*)parse:(NSDictionary *)JSONDict {
    if (!([JSONDict objectForKey:@"ID"] &&
          [JSONDict objectForKey:@"TEXT"] &&
          [JSONDict objectForKey:@"IS_CORRECT"] &&
          [JSONDict objectForKey:@"QUESTION_ID"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field");
        return nil;
    }
    
    Answer* answer = [[Answer alloc] init];
    //ID
    unsigned long long answerID = [[JSONDict objectForKey:@"ID"] unsignedLongLongValue];
    [answer setID:answerID];
    //text
    NSString* text = [JSONDict objectForKey:@"TEXT"];
    [answer setText:text];
    //isCorrect
    BOOL isCorrect = [[JSONDict objectForKey:@"IS_CORRECT"] boolValue];
    [answer setIsCorrect:isCorrect];
    //question_id
    unsigned long long question_id = [JSONDict[@"QUESTION_ID"] unsignedLongLongValue];
    [answer setRelatedQuestionID:question_id];

    return answer;
}

- (NSDictionary*)encode:(Answer*)a {
    NSDictionary* jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     [NSNumber numberWithUnsignedLongLong: a.ID], @"ID",
                                     a.text, @"TEXT",
                                     [NSNumber numberWithBool:a.isCorrect], @"IS_CORRECT",
                                     nil];
    return jsonDict;
}

@end
