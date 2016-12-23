//
//  Question.h
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "Asnwer.h"

@class Theme;
RLM_ARRAY_TYPE(Answer)

@interface Question : RLMObject

@property (assign, nonatomic) long long ID;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) RLMArray<Answer*><Answer> *answers;
@property (assign, nonatomic) BOOL approved;
@property (strong, nonatomic) Theme* theme;

@end
