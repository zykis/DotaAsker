//
//  User.h
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface User : NSObject

@property (assign, nonatomic) NSInteger ID;
@property (assign, nonatomic) NSInteger MMR;//Текущий рейтинг среди всех игроков
@property (assign, nonatomic) float KDA;//Отношение правильно отвеченных вопросов на неправильно отвеченные.
@property (assign, nonatomic) float GPM;//Насколько быстро вы отвечаете на вопросы
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *avatarImagePath;
@property (strong, nonatomic) NSString *wallpapersImagePath;
@property (assign, nonatomic) NSInteger matchPlayed;
@property (assign, nonatomic) NSInteger totalCorrectAnswers;
@property (assign, nonatomic) NSInteger totalIncorrectAnswers;

@end
