//
//  UserAnswerParser.m
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "UserAnswerParser.h"
#import "UserAnswer.h"
#import "UserParser.h"
#import "RoundParser.h"
#import "AnswerParser.h"
#import "QuestionParser.h"
#import "Round.h"
#import "User.h"
#import "Answer.h"
#import "Question.h"

@implementation UserAnswerParser

+ (UserAnswer*)parse:(NSDictionary *)JSONDict {
    if (!([JSONDict objectForKey:@"id"] &&
          [JSONDict objectForKey:@"created_on"] &&
          [JSONDict objectForKey:@"updated_on"] &&
          [JSONDict objectForKey:@"user"] &&
          [JSONDict objectForKey:@"question"] &&
          [JSONDict objectForKey:@"sec_for_answer"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field");
        return nil;
    }
    
    UserAnswer* userAnswer = [[UserAnswer alloc] init];
    
    // ID
    userAnswer.ID = [[JSONDict objectForKey:@"id"] longValue];
    
    // created_on
    userAnswer.createdOn = [self dateFromString:[JSONDict objectForKey:@"created_on"]];
    
    // updated_on
    userAnswer.updatedOn = [self dateFromString:[JSONDict objectForKey:@"updated_on"]];
    
    // sec_for_answer
    userAnswer.secForAnswer = [[JSONDict objectForKey:@"sec_for_answer"] integerValue];
    // user
    NSDictionary* userDict = [JSONDict objectForKey:@"user"];
    userAnswer.relatedUserID = [UserParser parse:userDict andChildren:NO].ID;
    // answer
    if (![JSONDict[@"answer"] isEqual: [NSNull null]]) {
        NSDictionary* answerDict = [JSONDict objectForKey:@"answer"];
        userAnswer.relatedAnswerID = [AnswerParser parse:answerDict].ID;
    }
    else {
        userAnswer.relatedAnswerID = [Answer emptyAnswer].ID;
    }
    // round
    userAnswer.relatedRoundID = [RoundParser parse:[JSONDict objectForKey:@"round"] andChildren:NO].ID;
    
    // question
    userAnswer.relatedQuestionID = [QuestionParser parse:[JSONDict objectForKey:@"question"]].ID;
    
    return userAnswer;
}

+ (NSData*)encode:(UserAnswer*)userAnswer {

    NSDictionary* roundDict = [RoundParser encode:[userAnswer relatedRound]];
    NSDictionary* userDict = [UserParser encode:[userAnswer relatedUser]];
    NSDictionary* answerDict = [AnswerParser encode:[userAnswer relatedAnswer]];
    NSDictionary* questionDict = [QuestionParser encode:[userAnswer relatedQuestion]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithUnsignedLongLong:userAnswer.ID], @"id",
                          roundDict, @"round",
                          userDict, @"user",
                          questionDict, @"question",
                          answerDict, @"answer",
                          [NSNumber numberWithUnsignedInteger: userAnswer.secForAnswer], @"sec_for_answer",
                          nil];
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    return data;
}

+ (NSDate*)dateFromString:(NSString*)dateString {
    NSDateFormatter* RFC3339DateFormatter = [[NSDateFormatter alloc] init];
    RFC3339DateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    RFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    RFC3339DateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    // example: NSString* string = @"1996-12-19T16:39:57-08:00";
    NSDate* date = [RFC3339DateFormatter dateFromString:dateString];
    return date;
}

@end
