//
//  Player.h
//  Real Estate Game
//
//  Created by Artem on 24/04/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Player : User

@property (strong, nonatomic) NSMutableArray *currentMatchesIDs;
@property (strong, nonatomic) NSMutableArray *recentMatchesIDs;
@property (strong, nonatomic) NSMutableArray *friendsIDs;

@end
