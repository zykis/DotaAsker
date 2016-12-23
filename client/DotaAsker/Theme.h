//
//  Theme.h
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
@import UIKit;

@interface Theme : RLMObject

@property (assign, nonatomic) long long ID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imageName;

@end
