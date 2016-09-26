//
//  ThemeParser.m
//  DotaAsker
//
//  Created by Artem on 15/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "ThemeParser.h"
#import "Theme.h"

@implementation ThemeParser

+ (Theme*)parse:(NSDictionary *)JSONDict {
    if (!([JSONDict objectForKey:@"id"] &&
          [JSONDict objectForKey:@"name"] &&
          [JSONDict objectForKey:@"image_name"]
          )) {
        NSLog(@"Parsing error: can't retrieve a field");
        return nil;
    }
    
    Theme* theme = [[Theme alloc] init];
    //ID
    unsigned long long themeID = [[JSONDict objectForKey:@"id"] unsignedLongLongValue];
    [theme setID:themeID];
    //name
    NSString* name = [JSONDict objectForKey:@"name"];
    [theme setName:name];
    //imageName
    NSString* imageName = [JSONDict objectForKey:@"image_name"];
    [theme setImageName:imageName];
    
    return theme;
}

- (NSDictionary*)encode:(Theme*)theme {
    NSDictionary* jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedLongLong: theme.ID], @"ID",
                              theme.name, @"NAME",
                              theme.imageName, @"IMAGE_NAME",
                              nil];
    return jsonDict;
}

@end
