//
//  UserAnswerParser.m
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "UserAnswerParser.h"
#import "UserAnswer.h"

@implementation UserAnswerParser

+ (UserAnswer*)parse:(NSData *)JSONData {
    NSError *error;
    if(!JSONData)
        return nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:&error];
    if (error) {
        return nil;
    }
    else {
        UserAnswer* userAnswer = [[UserAnswer alloc] init];
        userAnswer.ID = [[dict objectForKey:@"ID"] longValue];
        return userAnswer;
    }
}

@end
