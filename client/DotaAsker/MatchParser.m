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
          [JSONDict objectForKey:@"state"] &&
          [JSONDict objectForKey:@"mmr_gain"] &&
          [JSONDict objectForKey:@"updated_on"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field in MatchParser");
        return nil;
    }
    
    Match* match = [[Match alloc] init];
    
    //ID
    unsigned long long matchID = [[JSONDict objectForKey:@"id"] unsignedLongLongValue];
    [match setID:matchID];
    
    // created_on
    match.createdOn = [self dateFromString:[JSONDict objectForKey:@"created_on"]];
    
    // updated_on
    match.updatedOn = [self dateFromString:[JSONDict objectForKey:@"updated_on"]];
    
    //state
    NSUInteger state = [[JSONDict objectForKey:@"state"] unsignedIntegerValue];
    [match setState:state];
    
    //mmr
    [match setMmrGain:[[JSONDict objectForKey:@"mmr_gain"] unsignedIntegerValue]];
    
    //users
    NSArray* usersDict = [JSONDict objectForKey:@"users"];
    for (NSDictionary* userDict in usersDict) {
        User* u = [UserParser parse:userDict andChildren:NO];
        User* existingUser = [User objectForPrimaryKey:@(u.ID)];
        if (existingUser != nil) {
            [[match users] addObject:existingUser];
        }
        else {
            [[match users] addObject:u];
        }
    }
    
    //updated at
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString* utcDate = [JSONDict objectForKey:@"updated_on"];
    
    NSDate* updatedAt = [formatter dateFromString:utcDate];
    NSString* localizedDate = [NSDateFormatter localizedStringFromDate:updatedAt dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    [match setUpdatedOn:localizedDate];

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
    RFC3339DateFormatter = [[NSDateFormatter alloc] init];
    RFC3339DateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    RFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    RFC3339DateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    // example: NSString* string = @"1996-12-19T16:39:57-08:00";
    NSDate* date = [RFC3339DateFormatter dateFromString:dateString];
    return date;
}

@end
