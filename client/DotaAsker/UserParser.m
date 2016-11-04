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
    if ([JSONDict isEqual:[NSNull null]])
        return nil;
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
        if (!([JSONDict objectForKey:@"matches"] &&
              [JSONDict objectForKey:@"friends"]
              )) {
            NSLog(@"Parsing error: can't retrieve a field in UserParser");
            return nil;
        }
        
        NSArray* matchesDict = [JSONDict objectForKey:@"matches"];
        NSArray* friendsDict = [JSONDict objectForKey:@"friends"];
        for (NSDictionary* matchDict in matchesDict) {
            Match* m = [MatchParser parse:matchDict andChildren:YES];
            [[user matches] addObject:m];
        }
        for (NSDictionary* friendDict in friendsDict) {
            User* friend = [UserParser parse:friendDict andChildren:NO];
            [[user friends] addObject:friend];
        }
    }
    
    return user;
}

+ (NSDictionary*)encode:(User*)user {
    NSDictionary* jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedLongLong:user.ID], @"id",
                              user.name, @"username",
                              [NSNumber numberWithLong:user.MMR], @"rating",
                              [NSNumber numberWithInt:user.GPM], @"gpm",
                              [NSNumber numberWithFloat:user.KDA], @"kda",
                              user.avatarImageName, @"avatar_image_name",
                              user.wallpapersImageName, @"wallpapers_image_name",
                              [NSNumber numberWithLong:user.totalCorrectAnswers], @"total_correct_answers",
                              [NSNumber numberWithLong:user.totalIncorrectAnswers], @"total_incorrect_answers",
                              nil];
    return jsonDict;
}

@end
