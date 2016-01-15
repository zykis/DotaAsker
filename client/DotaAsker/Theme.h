//
//  Theme.h
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface Theme : NSObject 

@property (assign, nonatomic) unsigned long long ID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imageName;

@end
