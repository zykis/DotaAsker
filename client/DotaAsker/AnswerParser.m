//
//  AnswerParser.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

// Local
#import "AnswerParser.h"
#import "Answer.h"
#import "Helper.h"


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

+ (NSDictionary*)encode:(Answer*)a {
    NSString* locale = [Helper currentLocale];
    NSDictionary* jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     [NSNumber numberWithLongLong:a.ID], @"id",
                                     a.text, [NSString stringWithFormat: @"text_%@", locale],
                                     [NSNumber numberWithBool:a.isCorrect], @"is_correct",
                                     nil];
    return jsonDict;
}

@end
