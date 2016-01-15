//
//  UserParser.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "UserParser.h"
#import "User.h"

@implementation UserParser

- (User*)parse:(NSDictionary *)JSONDict {
    if (!([JSONDict objectForKey:@"ID"] &&
          [JSONDict objectForKey:@"USERNAME"] &&
          [JSONDict objectForKey:@"RATING"] &&
          [JSONDict objectForKey:@"GPM"] &&
          [JSONDict objectForKey:@"KDA"] &&
          [JSONDict objectForKey:@"AVATAR_IMAGE_NAME"] &&
          [JSONDict objectForKey:@"WALLPAPERS_IMAGE_NAME"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field");
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
    return user;
}

@end
