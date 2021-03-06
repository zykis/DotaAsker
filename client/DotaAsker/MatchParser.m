//
//  MatchParser.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "MatchParser.h"
#import "RoundParser.h"
#import "UserParser.h"
#import "Match.h"
#import "Round.h"
#import "User.h"
//#import "Player.h"
#import "UserAnswer.h"

@implementation MatchParser

+ (Match*)parse:(NSDictionary *)JSONDict andChildren:(BOOL)bParseChildren {
    if (!([JSONDict objectForKey:@"id"] &&
          [JSONDict objectForKey:@"created_on"] &&
          [JSONDict objectForKey:@"updated_on"] &&
          [JSONDict objectForKey:@"users"] &&
          [JSONDict objectForKey:@"winner"] &&
          [JSONDict objectForKey:@"state"] &&
          [JSONDict objectForKey:@"finish_reason"] &&
          [JSONDict objectForKey:@"mmr_gain"] &&
          [JSONDict objectForKey:@"updated_on"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field in MatchParser");
        return nil;
    }
    
    Match* match = [[Match alloc] init];
    
    // ID
    unsigned long long matchID = [[JSONDict objectForKey:@"id"] unsignedLongLongValue];
    [match setID:matchID];
    
    // created_on
    match.createdOn = [self dateFromString:[JSONDict objectForKey:@"created_on"]];
    
    // updated_on
    match.updatedOn = [self dateFromString:[JSONDict objectForKey:@"updated_on"]];
    
    // state
    NSInteger state = [[JSONDict objectForKey:@"state"] integerValue];
    [match setState:state];
    
    // finish_reason
    NSInteger finishReason = [[JSONDict objectForKey:@"finish_reason"] integerValue];
    match.finishReason = finishReason;
    
    // mmr
    [match setMmrGain:[[JSONDict objectForKey:@"mmr_gain"] unsignedIntegerValue]];
    
    // hidden
    if ([JSONDict objectForKey:@"hidden"] != nil)
        [match setHidden:[[JSONDict objectForKey:@"hidden"] boolValue]];
    
    // users
    NSArray* usersDict = [JSONDict objectForKey:@"users"];
    for (NSDictionary* userDict in usersDict) {
        User* u = [UserParser parse:userDict andChildren:NO];
        [[match users] addObject: u];
    }
    
    // winner
    NSDictionary* winnerDict = [JSONDict objectForKey:@"winner"];
    User* winner = [UserParser parse:winnerDict andChildren:NO];
    [match setWinner:winner];
    

    if (bParseChildren) {
        if (!([JSONDict objectForKey:@"rounds"])) {
            NSLog(@"Parsing error: can't retrieve a field in MatchParser");
            return nil;
        }
        //rounds
        NSMutableArray* roundsDict = [JSONDict objectForKey:@"rounds"];
        for (NSDictionary* roundDict in roundsDict) {
            Round* r = [RoundParser parse:roundDict andChildren:YES];
            [[match rounds] addObject:r];
        }
    }
    
    return match;
}

+ (NSDictionary*)encode:(Match*)match andChildren:(BOOL)bEncodeChildren {
    NSMutableDictionary *dict = [[NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithUnsignedLongLong:[match ID]], @"id",
                          [NSNumber numberWithUnsignedLong:[match state]], @"state",
                          nil] mutableCopy];
//    if (bEncodeChildren) {
//        // encode rounds also
//        for (Round* r in [match rounds]) {
//            NSDictionary* roundDict = [RoundParser encode:r];
//        }
//    }
    return dict;
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
