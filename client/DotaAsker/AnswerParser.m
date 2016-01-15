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
          [JSONDict objectForKey:@"IS_CORRECT"]
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

    return answer;
}
@end
