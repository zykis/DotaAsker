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

+ (Answer*)parse:(NSDictionary *)JSONDict {
    if ([JSONDict isEqual:[NSNull null]]) {
        // Well, that's really bad practice....
        Answer* answer = [[Answer alloc] init];
        return answer;
    }
    
    if (!([JSONDict objectForKey:@"id"] &&
          [JSONDict objectForKey:@"text"] &&
          [JSONDict objectForKey:@"is_correct"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field");
        return nil;
    }
    
    Answer* answer = [[Answer alloc] init];
    //ID
    unsigned long long answerID = [[JSONDict objectForKey:@"id"] unsignedLongLongValue];
    [answer setID:answerID];
    //text
    NSString* text = [JSONDict objectForKey:@"text"];
    [answer setText:text];
    //isCorrect
    BOOL isCorrect = [[JSONDict objectForKey:@"is_correct"] boolValue];
    [answer setIsCorrect:isCorrect];

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
