//
//  RoundService.m
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "RoundService.h"
#import "RoundParser.h"
#import "Match.h"

@implementation RoundService

- (Round*)currentRoundforMatch:(Match *)match {
    Round* currentRound;
    NSUInteger index = 0;
    for (Round* r in [match rounds]) {
        if (([r round_state] != ROUND_FINISHED) && ([r round_state] != ROUND_TIME_ELAPSED)
            && ([r round_state] != ROUND_NOT_STARTED))
            index++;
    }
    currentRound = [[match rounds] objectAtIndex:index];
    return currentRound;
}

- (Round_State)roundStateFromServerState:(NSUInteger)serverRoundState {
    Round_State rs = serverRoundState;
    
    if(rs == 3) { // ROUND_ANSWERING
        if([_match nextMoveUserID] == [[Player instance] ID])
            rs = ROUND_PLAYER_ASWERING;
        else
            rs = ROUND_OPPONENT_ANSWERING;
    }
    else if(rs == 4) { //ROUND_REPLYING
        if([_match nextMoveUserID] == [[Player instance] ID])
            rs = ROUND_PLAYER_REPLYING;
        else
            rs = ROUND_OPPONENT_REPLYING;
    }
    
    return rs;
}

@end
