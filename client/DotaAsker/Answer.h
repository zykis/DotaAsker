//
//  Answer.h
//  DotaAsker
//
//  Created by Artem on 22/09/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface Answer : RLMObject

@property (assign, nonatomic) long long ID;
@property (strong, nonatomic) NSString* text;
@property (assign, nonatomic) BOOL isCorrect;
+ (Answer*)emptyAnswer;

@end
