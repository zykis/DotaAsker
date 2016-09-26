//
//  UserParser.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "UserParser.h"
#import "MatchParser.h"
#import "User.h"

@implementation UserParser

+ (User*)parse:(NSDictionary *)JSONDict andChildren:(BOOL)bParseChildren {
    if (!([JSONDict objectForKey:@"id"] &&
          [JSONDict objectForKey:@"username"] &&
          [JSONDict objectForKey:@"mmr"] &&
          [JSONDict objectForKey:@"gpm"] &&
          [JSONDict objectForKey:@"kda"] &&
          [JSONDict objectForKey:@"avatar_image_name"] &&
          [JSONDict objectForKey:@"wallpapers_image_name"] &&
          [JSONDict objectForKey:@"role"] &&
          [JSONDict objectForKey:@"total_correct_answers"] &&
          [JSONDict objectForKey:@"total_incorrect_answers"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field in UserParser");
        return nil;
    }
    
    User* user = [[User alloc] init];
    [user setID:[[JSONDict objectForKey:@"id"] unsignedLongLongValue]];
    [user setName:[JSONDict objectForKey:@"username"]];
    [user setMMR:[[JSONDict objectForKey:@"mmr"] integerValue]];
    [user setGPM:[[JSONDict objectForKey:@"gpm"] integerValue]];
    [user setKDA:[[JSONDict objectForKey:@"kda"] floatValue]];
    [user setAvatarImageName:[JSONDict objectForKey:@"avatar_image_name"]];
    [user setWallpapersImageName:[JSONDict objectForKey:@"wallpapers_image_name"]];
    [user setRole:(ROLE)[JSONDict[@"role"] integerValue]];
    [user setTotalCorrectAnswers: [[JSONDict objectForKey:@"total_correct_answers"] integerValue]];
    [user setTotalIncorrectAnswers: [[JSONDict objectForKey:@"total_incorrect_answers"] integerValue]];
    if (bParseChildren) {
        if (!([JSONDict objectForKey:@"current_matches"] &&
              [JSONDict objectForKey:@"recent_matches"] &&
              [JSONDict objectForKey:@"friends"]
              )) {
            NSLog(@"Parsing error: can't retrieve a field in UserParser");
            return nil;
        }
        
        NSArray* currentMatchesDict = [JSONDict objectForKey:@"current_matches"];
        NSArray* recentMatchesDict = [JSONDict objectForKey:@"recent_matches"];
        NSArray* friendsDict = [JSONDict objectForKey:@"friends"];
        for (NSDictionary* matchDict in currentMatchesDict) {
            Match* m = [MatchParser parse:matchDict andChildren:YES];
            [[user currentMatches] addObject:m];
        }
        for (NSDictionary* matchDict in recentMatchesDict) {
            Match* m = [MatchParser parse:matchDict andChildren:YES];
            [[user recentMatches] addObject:m];
        }
        for (NSDictionary* friendDict in friendsDict) {
            User* friend = [UserParser parse:friendDict andChildren:NO];
            [[user friends] addObject:friend];
        }
    }
    
    return user;
}

- (NSDictionary*)encode:(User*)user {
    NSArray* matchesIDs = [user.currentMatches arrayByAddingObjectsFromArray:user.recentMatches];
    NSDictionary* jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedLongLong:user.ID], @"ID",
                              user.name, @"USERNAME",
                              [NSNumber numberWithLong:user.MMR], @"RATING",
                              [NSNumber numberWithInt:user.GPM], @"GPM",
                              [NSNumber numberWithFloat:user.KDA], @"KDA",
                              user.avatarImageName, @"AVATAR_IMAGE_NAME",
                              user.wallpapersImageName, @"WALLPAPERS_IMAGE_NAME",
                              matchesIDs, @"MATCHES_IDS",
                              [NSNumber numberWithLong:user.totalCorrectAnswers], @"TOTAL_CORRECT_ANSWERS",
                              [NSNumber numberWithLong:user.totalIncorrectAnswers], @"TOTAL_INCORRECT_ANSWERS",
                              nil];
    return jsonDict;
}

@end
