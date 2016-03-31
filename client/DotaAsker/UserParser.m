//
//  UserParser.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "UserParser.h"
#import "User.h"
#import "MatchService.h"

@implementation UserParser

- (User*)parse:(NSDictionary *)JSONDict {
    if (!([JSONDict objectForKey:@"ID"] &&
          [JSONDict objectForKey:@"USERNAME"] &&
          [JSONDict objectForKey:@"RATING"] &&
          [JSONDict objectForKey:@"GPM"] &&
          [JSONDict objectForKey:@"KDA"] &&
          [JSONDict objectForKey:@"AVATAR_IMAGE_NAME"] &&
          [JSONDict objectForKey:@"WALLPAPERS_IMAGE_NAME"] &&
          [JSONDict objectForKey:@"CURRENT_MATCHES_IDS"] &&
          [JSONDict objectForKey:@"RECENT_MATCHES_IDS"] &&
          [JSONDict objectForKey:@"TOTAL_CORRECT_ANSWERS"] &&
          [JSONDict objectForKey:@"TOTAL_INCORRECT_ANSWERS"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field in UserParser");
        return nil;
    }
    
    User* user = [[User alloc] init];
    [user setID:[[JSONDict objectForKey:@"ID"] unsignedLongLongValue]];
    [user setName:[JSONDict objectForKey:@"USERNAME"]];
    [user setMMR:[[JSONDict objectForKey:@"RATING"] integerValue]];
    [user setGPM:[[JSONDict objectForKey:@"GPM"] integerValue]];
    [user setKDA:[[JSONDict objectForKey:@"KDA"] floatValue]];
    [user setAvatarImageName:[JSONDict objectForKey:@"AVATAR_IMAGE_NAME"]];
    [user setWallpapersImageName:[JSONDict objectForKey:@"WALLPAPERS_IMAGE_NAME"]];
    NSArray* currentMatchesIDs = [[JSONDict objectForKey:@"CURRENT_MATCHES_IDS"] mutableCopy];
    NSArray* recentMatchesIDs = [[JSONDict objectForKey:@"RECENT_MATCHES_IDS"] mutableCopy];
    [[user currentMatchesIDs] addObjectsFromArray:currentMatchesIDs];
    [[user recentMatchesIDs] addObjectsFromArray:recentMatchesIDs];
    [user setTotalCorrectAnswers: [[JSONDict objectForKey:@"TOTAL_CORRECT_ANSWERS"] integerValue]];
    [user setTotalIncorrectAnswers: [[JSONDict objectForKey:@"TOTAL_INCORRECT_ANSWERS"] integerValue]];
    
    return user;
}

- (NSDictionary*)encode:(User*)user {
    NSArray* matchesIDs = [user.currentMatchesIDs arrayByAddingObjectsFromArray:user.recentMatchesIDs];
    NSDictionary* jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedLongLong:user.ID], @"ID",
                              user.name, @"USERNAME",
                              [NSNumber numberWithInt:user.MMR], @"RATING",
                              [NSNumber numberWithInt:user.GPM], @"GPM",
                              [NSNumber numberWithFloat:user.KDA], @"KDA",
                              user.avatarImageName, @"AVATAR_IMAGE_NAME",
                              user.wallpapersImageName, @"WALLPAPERS_IMAGE_NAME",
                              matchesIDs, @"MATCHES_IDS",
                              [NSNumber numberWithInt:user.totalCorrectAnswers], @"TOTAL_CORRECT_ANSWERS",
                              [NSNumber numberWithInt:user.totalIncorrectAnswers], @"TOTAL_INCORRECT_ANSWERS",
                              nil];
    return jsonDict;
}

@end
