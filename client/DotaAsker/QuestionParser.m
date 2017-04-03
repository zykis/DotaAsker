//
//  QuestionParser.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

// Local
#import "QuestionParser.h"
#import "Question.h"
#import "AnswerParser.h"
#import "ThemeParser.h"
#import "Theme.h"
#import "Helper.h"


@implementation QuestionParser

+ (Question*)parse:(NSDictionary *)JSONDict {
    if (!([JSONDict objectForKey:@"id"] &&
          [JSONDict objectForKey:@"text"] &&
          [JSONDict objectForKey:@"image_name"] &&
          [JSONDict objectForKey:@"answers"] &&
          [JSONDict objectForKey:@"theme"] &&
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
    //theme
    NSDictionary *themeDict = [JSONDict objectForKey:@"theme"];
    Theme* theme = [ThemeParser parse:themeDict];
    [question setTheme:theme];

    return question;
}

+ (NSDictionary*)encode:(Question*)question {
    NSMutableArray* answers = [[NSMutableArray alloc] init];
    for (Answer* a in [question answers]) {
        NSDictionary* aDict = [AnswerParser encode:a];
        [answers addObject:aDict];
    }
    
    NSString* locale = [Helper currentLocale];
    NSMutableDictionary* jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedLongLong: question.ID], @"id",
                              question.text, [NSString stringWithFormat: @"text_%@", locale],
                              answers, @"answers",
                              question.imageName, @"image_name",
                              nil];
    return jsonDict;
}


@end
