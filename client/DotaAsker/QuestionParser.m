//
//  QuestionParser.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "QuestionParser.h"
#import "Question.h"

@implementation QuestionParser

- (Question*)parse:(NSDictionary *)JSONDict {
    if (!([JSONDict objectForKey:@"ID"] &&
          [JSONDict objectForKey:@"THEME_ID"] &&
          [JSONDict objectForKey:@"TEXT"] &&
          [JSONDict objectForKey:@"IMAGE_NAME"] &&
          [JSONDict objectForKey:@"ANSWERS_IDS"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field");
        return nil;
    }
    
    Question* question = [[Question alloc] init];
    //ID
    unsigned long long questionID = [[JSONDict objectForKey:@"ID"] unsignedLongLongValue];
    [question setID:questionID];
    //themeID
    unsigned long long themeID = [[JSONDict objectForKey:@"THEME_ID"] unsignedLongLongValue];
    [question setThemeID:themeID];
    //text
    NSString* text = [JSONDict objectForKey:@"TEXT"];
    [question setText:text];
    //imageName
    NSString* imageName = [JSONDict objectForKey:@"IMAGE_NAME"];
    [question setImageName:imageName];
    //answersIDs
    NSMutableArray* answersIDs = [JSONDict objectForKey:@"ANSWERS_IDS"];
    [question setAnswersIDs:answersIDs];

    return question;
}

- (NSDictionary*)encode:(Question*)question {
    NSDictionary* jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedLongLong: question.ID], @"ID",
                              [NSNumber numberWithUnsignedLongLong: question.themeID], @"THEME_ID",
                              question.text, @"TEXT",
                              question.imageName, @"IMAGE_NAME",
                              question.answersIDs, @"ANSWERS_IDS",
                              nil];
    return jsonDict;
}


@end
