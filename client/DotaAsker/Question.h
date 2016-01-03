//
//  Question.h
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Question : NSObject <NSCoding>

@property (assign, nonatomic) NSInteger ID;
@property (assign, nonatomic) NSInteger *themeID;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSMutableArray *answersIDs;

@end
