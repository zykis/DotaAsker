//
//  Question.h
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Question : NSObject

@property (assign, nonatomic) unsigned long long ID;
@property (assign, nonatomic) unsigned long long themeID;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSMutableArray *answersIDs;

@end
