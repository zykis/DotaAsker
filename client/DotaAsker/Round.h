//
//  Round.h
//  DotaAsker
//
//  Created by Artem on 15/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Theme.h"
/*
 раунд может находится в одном из семи состояний
 1 - Раунд ещё не началася - NOT_STARTED
 2 - Раунд закончился (оба игрока ответили на вопросы) - FINISHED
 3 - Раунд истёк по времени - TIME_ELAPSED
 4 - Игрок1 выбирает тему и отвечает на вопросы - PLAYER_ASWERING
 5 - Игрок2 отвечает на вопросы выбранной Игроком1 темы - OPPONENT_ANSWERING
 6 - Игрок2 выбирает тему и отвечает на вопросы - OPPONENT_REPLYING
 7 - Игрок1 отвечает на вопросы выбранной Игроком2 темы - PLAYER_REPLYING
 //(0-NOT_STARTED, 1-FINISHED, 2-TIME_ELAPSED, 3-PLAYER_ASWERING, 4-OPPONENT_ANSWERING, 5-PLAYER_REPLYING, 6-OPPONENT_REPLYING)
 
 В зависимости от этих состояний, происходит отрисовка соответствующего RoundView
 Переходы в состояниях контролируют данные внутри класса.
 В случае несоответствия - кидаем исключение
 Например: (При переходе в состояние FINISHED, отсутствуют элементы в массивах answersFirstPlayer или answersSecondPlayer)
*/
typedef enum {ROUND_NOT_STARTED = 0, ROUND_FINISHED, ROUND_TIME_ELAPSED, ROUND_PLAYER_ASWERING, ROUND_OPPONENT_ANSWERING, ROUND_PLAYER_REPLYING, ROUND_OPPONENT_REPLYING} Round_State;

@interface Round : NSObject

@property (assign, nonatomic) unsigned long long ID;
@property (assign, nonatomic) Round_State round_state;//текущее состояние раунда
@property (strong, nonatomic) Theme* theme;//выбранная тема
@property (strong, nonatomic) NSMutableArray* questions;//список вопросов
@property (strong, nonatomic) NSMutableArray* userAnswers;//список ответов

@end
