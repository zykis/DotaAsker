//
//  QuestionParser.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "QuestionParser.h"
#import "Question.h"
#import "AnswerParser.h"

@implementation QuestionParser

+ (Question*)parse:(NSDictionary *)JSONDict {
    if (!([JSONDict objectForKey:@"id"] &&
          [JSONDict objectForKey:@"text"] &&
          [JSONDict objectForKey:@"image_name"] &&
          [JSONDict objectForKey:@"answers"] &&
          [JSONDict objectForKey:@"approved"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field");
        return nil;
    }
    
    Question* question = [[Question alloc] init];
    //ID
    unsigned long long questionID = [[JSONDict objectForKey:@"id"] unsignedLongLongValue];
    [question setID:questionID];
    //text
    NSString* text = [JSONDict objectForKey:@"text"];
    [question setText:text];
    //imageName
    NSString* imageName = [JSONDict objectForKey:@"image_name"];
    [question setImageName:imageName];
    //approved
    BOOL approved = [JSONDict[@"approved"] boolValue];
    [question setApproved:approved];
    //answers
    NSArray* answersDict = [JSONDict objectForKey:@"answers"];
    for (NSDictionary* answerDict in answersDict) {
        Answer *a = [AnswerParser parse:answerDict];
        [[question answers] addObject:a];
    }

    return question;
}

- (NSDictionary*)encode:(Question*)question {
    NSDictionary* jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedLongLong: question.ID], @"ID",
                              question.text, @"TEXT",
                              question.imageName, @"IMAGE_NAME",
                              question.answers, @"ANSWERS_IDS",
                              nil];
    return jsonDict;
}


@end
