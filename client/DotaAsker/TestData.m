//
//  TestData.m
//  DotaAsker
//
//  Created by Artem on 01/08/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "TestData.h"
#import "Theme.h"
#import "Question.h"
#import "Player.h"
#import "Match.h"
#import "Round.h"
#import "Question.h"
#import "UserAnswer.h"
#import "Answer.h"

@implementation TestData

+ (void)generateTestGameData {
//    User *user2 = [[User alloc] init];
//    [user2 setName:@"Pascal"];
//    [user2 setAvatar:[UIImage imageNamed:@"avatar_tinker.png"]];
//    
//    User *user3 = [[User alloc] init];
//    [user3 setName:@"Patrick"];
//    [user3 setAvatar:[UIImage imageNamed:@"avatar_axe.png"]];
//    
//    Match *matchFinished = [self generateFinishedMatchVSUser:user2];
//    Match *matchRunning = [self generateRunningMatchVSUser:user3];
//    Match *matchFinishing = [self generateFinishingMatchVSUser:user2];
    
    Player *player = [Player instance];
    [player setName:@"Zykis"];
    [player setAvatar:[UIImage imageNamed:@"avatar_tiny.png"]];
    [player setWallpapers:[UIImage imageNamed:@"wallpaper_antimage_1.jpg"]];
    
//    [[player currentMatches] addObject:matchRunning];
//    [[player currentMatches] addObject:matchFinishing];
//    [[player recentMatches] addObject:matchFinished];
}

+ (Match*)generateFinishedMatchVSUser:(User *)anOpponent {
    Match *matchFinished = [[Match alloc] init];
    [matchFinished setOpponent:anOpponent];
    
    [self generateFinishedRound:[[matchFinished rounds] objectAtIndex:0]];
    [self generateFinishedRound:[[matchFinished rounds] objectAtIndex:1]];
    [self generateFinishedRound:[[matchFinished rounds] objectAtIndex:2]];
    [self generateFinishedRound:[[matchFinished rounds] objectAtIndex:3]];
    [self generateFinishedRound:[[matchFinished rounds] objectAtIndex:4]];
    [self generateFinishedRound:[[matchFinished rounds] objectAtIndex:5]];
    
    return matchFinished;
}

+ (Match*)generateRunningMatchVSUser:(User *)anOpponent {
    Match *matchRunning = [[Match alloc] init];
    [matchRunning setOpponent:anOpponent];
    
    [self generateFinishedRound:[[matchRunning rounds] objectAtIndex:0]];
    [self generateFinishedRound:[[matchRunning rounds] objectAtIndex:1]];
    [self generateFinishedRound:[[matchRunning rounds] objectAtIndex:2]];
    [self generateFinishedRound:[[matchRunning rounds] objectAtIndex:3]];
    [self generatePlayerReplyingRound:[[matchRunning rounds] objectAtIndex:4]];
    [self generateNotStartedRound:[[matchRunning rounds] objectAtIndex:5]];
    
    return matchRunning;
}

+ (Match*)generateFinishingMatchVSUser:(User *)anOpponent {
    Match *matchFinishing = [[Match alloc] init];
    [matchFinishing setOpponent:anOpponent];
    
    [self generateFinishedRound:[[matchFinishing rounds] objectAtIndex:0]];
    [self generateFinishedRound:[[matchFinishing rounds] objectAtIndex:1]];
    [self generateFinishedRound:[[matchFinishing rounds] objectAtIndex:2]];
    [self generateFinishedRound:[[matchFinishing rounds] objectAtIndex:3]];
    [self generateFinishedRound:[[matchFinishing rounds] objectAtIndex:4]];
    [self generatePlayerReplyingRound:[[matchFinishing rounds] objectAtIndex:5]];
    
    return matchFinishing;
}

+ (Match*)generateNewMatchVSUser:(User *)anOpponent {
    Match *newMatch = [[Match alloc] init];
    [newMatch setOpponent:anOpponent];
    
    BOOL bPlayerFirst = arc4random_uniform(2) == 1? NO: YES;
    if (bPlayerFirst) {
        [self generatePlayerAnsweringRound:[[newMatch rounds] objectAtIndex:0]];
    }
    else {
        [self generateOpponentAnsweringRound:[[newMatch rounds] objectAtIndex:0]];
    }
    [self generateNotStartedRound:[[newMatch rounds] objectAtIndex:1]];
    [self generateNotStartedRound:[[newMatch rounds] objectAtIndex:2]];
    [self generateNotStartedRound:[[newMatch rounds] objectAtIndex:3]];
    [self generateNotStartedRound:[[newMatch rounds] objectAtIndex:4]];
    [self generateNotStartedRound:[[newMatch rounds] objectAtIndex:5]];
    
    return newMatch;
}

+ (void)generateNotStartedRound:(Round *)roundNotStarted {
//    [roundNotStarted setThemes:[Theme getAllThemes]];
    [roundNotStarted setRound_state:ROUND_NOT_STARTED];
}

+ (void)generatePlayerAnsweringRound:(Round *)roundPlayerAnswering {
    [roundPlayerAnswering setTheme:[[Theme getAllThemes] objectAtIndex:arc4random_uniform(2)]];
    [roundPlayerAnswering setRound_state:ROUND_PLAYER_ASWERING];
}

+ (void)generateOpponentAnsweringRound:(Round *)roundOpponentAnswering {
    [roundOpponentAnswering setTheme:[[Theme getAllThemes] objectAtIndex:arc4random_uniform(2)]];
    [roundOpponentAnswering setRound_state:ROUND_OPPONENT_ANSWERING];
}

+ (void)generatePlayerReplyingRound:(Round *)roundPlayerReplying {
    [roundPlayerReplying setTheme:[[Theme getAllThemes] objectAtIndex:arc4random_uniform(2)]];
    
    //Questions
    Question *question1 = [self generateQuestionOnTheme:roundPlayerReplying.theme];
    Question *question2 = [self generateQuestionOnTheme:roundPlayerReplying.theme];
    Question *question3 = [self generateQuestionOnTheme:roundPlayerReplying.theme];
    
    [roundPlayerReplying setQuestions:[NSMutableArray arrayWithObjects:question1, question2,
                                       question3, nil]];
    
    //Opponent answers
    UserAnswer *opponent_answer1 = [[UserAnswer alloc] initAnswerRelatedToQuestion:question1];
    UserAnswer *opponent_answer2 = [[UserAnswer alloc] initAnswerRelatedToQuestion:question1];
    UserAnswer *opponent_answer3 = [[UserAnswer alloc] initAnswerRelatedToQuestion:question1];
    
    [opponent_answer1 setRelatedAnswer:[[question1 answers] objectAtIndex:arc4random_uniform(3)]];
    [opponent_answer2 setRelatedAnswer:[[question2 answers] objectAtIndex:arc4random_uniform(3)]];
    [opponent_answer3 setRelatedAnswer:[[question3 answers] objectAtIndex:arc4random_uniform(3)]];
    
    [roundPlayerReplying setAnswersOpponent:[NSMutableArray arrayWithObjects:opponent_answer1, opponent_answer2, opponent_answer3, nil]];
    
    [roundPlayerReplying setRound_state:ROUND_PLAYER_REPLYING];
}

+ (void)generateFinishedRound:(Round *)roundFinished {
    [roundFinished setTheme:[[Theme getAllThemes] objectAtIndex:arc4random_uniform(2)]];
    
    //Questions
    Question *question1 = [self generateQuestionOnTheme:[roundFinished theme]];
    Question *question2 = [self generateQuestionOnTheme:[roundFinished theme]];
    Question *question3 = [self generateQuestionOnTheme:[roundFinished theme]];

    [roundFinished setQuestions:[NSMutableArray arrayWithObjects:question1, question2,                            question3, nil]];
    
    //Player answers
    UserAnswer *player_answer1 = [[UserAnswer alloc] initAnswerRelatedToQuestion:question1];
    UserAnswer *player_answer2 = [[UserAnswer alloc] initAnswerRelatedToQuestion:question1];
    UserAnswer *player_answer3 = [[UserAnswer alloc] initAnswerRelatedToQuestion:question1];
    
    [player_answer1 setRelatedAnswer:[[question1 answers] objectAtIndex:arc4random_uniform(3)]];
    [player_answer2 setRelatedAnswer:[[question2 answers] objectAtIndex:arc4random_uniform(3)]];
    [player_answer3 setRelatedAnswer:[[question3 answers] objectAtIndex:arc4random_uniform(3)]];
    
    [roundFinished setAnswersPlayer:[NSMutableArray arrayWithObjects:player_answer1, player_answer2, player_answer3, nil]];
    
    //Opponent answers
    UserAnswer *opponent_answer1 = [[UserAnswer alloc] initAnswerRelatedToQuestion:question1];
    UserAnswer *opponent_answer2 = [[UserAnswer alloc] initAnswerRelatedToQuestion:question1];
    UserAnswer *opponent_answer3 = [[UserAnswer alloc] initAnswerRelatedToQuestion:question1];
    
    [opponent_answer1 setRelatedAnswer:[[question1 answers] objectAtIndex:arc4random_uniform(3)]];
    [opponent_answer2 setRelatedAnswer:[[question2 answers] objectAtIndex:arc4random_uniform(3)]];
    [opponent_answer3 setRelatedAnswer:[[question3 answers] objectAtIndex:arc4random_uniform(3)]];
    
    [roundFinished setAnswersOpponent:[NSMutableArray arrayWithObjects:opponent_answer1, opponent_answer2, opponent_answer3, nil]];
    
    [roundFinished setRound_state:ROUND_FINISHED];
}

+ (Question*)generateQuestionOnTheme:(Theme *)aTheme {
    Question *newQuestion = [[Question alloc] init];
    [newQuestion setTheme:aTheme];
    if ([[aTheme name] isEqualToString:@"Lore"]) {
        NSInteger num = arc4random_uniform(2);
        switch (num) {
            case 0: {
                [newQuestion setText:@"What race Invoker belong to?"];
                
                Answer *answer1 = [[Answer alloc] init];
                [answer1 setText:@"Orc"];
                [answer1 setIsCorrect:NO];
                
                Answer *answer2 = [[Answer alloc] init];
                [answer2 setText:@"Human"];
                [answer2 setIsCorrect:NO];
                
                Answer *answer3 = [[Answer alloc] init];
                [answer3 setText:@"High Elf"];
                [answer3 setIsCorrect:NO];
                
                Answer *answer4 = [[Answer alloc] init];
                [answer4 setText:@"Blood Elf"];
                [answer4 setIsCorrect:YES];
                
                [newQuestion setAnswers:[[NSArray arrayWithObjects:answer1, answer2, answer3, answer4, nil] mutableCopy]];
                [newQuestion setImage:[UIImage imageNamed:@"lore_invoker_race.jpg"]];
                break;
            }
            case 1: {
                [newQuestion setText:@"What da fuck is a treant?"];
                
                Answer *answer1 = [[Answer alloc] init];
                [answer1 setText:@"Beast"];
                
                Answer *answer2 = [[Answer alloc] init];
                [answer2 setText:@"Orc"];
                
                Answer *answer3 = [[Answer alloc] init];
                [answer3 setText:@"Machine"];
                
                Answer *answer4 = [[Answer alloc] init];
                [answer4 setText:@"Fucking tree"];
                [answer4 setIsCorrect:YES];
                
                [newQuestion setAnswers:[[NSArray arrayWithObjects:answer1, answer2, answer3, answer4, nil] mutableCopy]];
                [newQuestion setImage:[UIImage imageNamed:@"lore_treant.jpg"]];
                break;
            }
            case 2: {
                [newQuestion setText:@"Who of these characters is a child?"];
                
                Answer *answer1 = [[Answer alloc] init];
                [answer1 setText:@"Treant Protector"];
                
                Answer *answer2 = [[Answer alloc] init];
                [answer2 setText:@"Faceless Void"];
                
                Answer *answer3 = [[Answer alloc] init];
                [answer3 setText:@"Pugna"];
                [answer3 setIsCorrect:YES];
                
                Answer *answer4 = [[Answer alloc] init];
                [answer4 setText:@"Bane"];
                
                [newQuestion setAnswers:[[NSArray arrayWithObjects:answer1, answer2, answer3, answer4, nil] mutableCopy]];
                [newQuestion setImage:[UIImage imageNamed:@"lore_child.jpg"]];
                break;
            }
        }
        
    }
    else if ([[aTheme name] isEqualToString:@"Tournaments"]) {
        NSInteger num = arc4random_uniform(2);
        switch (num) {
            case 0: {
                [newQuestion setText:@"Who take 1st place in International 1?"];
                
                Answer *answer1 = [[Answer alloc] init];
                [answer1 setText:@"Tongfu"];
                
                Answer *answer2 = [[Answer alloc] init];
                [answer2 setText:@"NatusVincere"];
                [answer2 setIsCorrect:YES];
                
                Answer *answer3 = [[Answer alloc] init];
                [answer3 setText:@"iG"];
                
                Answer *answer4 = [[Answer alloc] init];
                [answer4 setText:@"EvilGenuises"];
                
                [newQuestion setAnswers:[[NSArray arrayWithObjects:answer1, answer2, answer3, answer4, nil] mutableCopy]];
                [newQuestion setImage:[UIImage imageNamed:@"tournaments_TI1_winner.jpg"]];
                break;
            }
            case 1: {
                [newQuestion setText:@"What is a 1st place price in TI-2015?"];
                
                Answer *answer1 = [[Answer alloc] init];
                [answer1 setText:@"6.000.000$"];
                [answer1 setIsCorrect:YES];
                
                Answer *answer2 = [[Answer alloc] init];
                [answer2 setText:@"1.500.000$"];
                
                Answer *answer3 = [[Answer alloc] init];
                [answer3 setText:@"16.000.000$"];
                
                Answer *answer4 = [[Answer alloc] init];
                [answer4 setText:@"1.000.000$"];
                
                [newQuestion setAnswers:[[NSArray arrayWithObjects:answer1, answer2, answer3, answer4, nil] mutableCopy]];
                [newQuestion setImage:[UIImage imageNamed:@"tournaments_TI2015_prizepool.jpg"]];
                break;
            }
            case 2: {
                [newQuestion setText:@"The International 1 Grand-Final qualification"];
                
                Answer *answer1 = [[Answer alloc] init];
                [answer1 setText:@"BestOf3"];
                
                Answer *answer2 = [[Answer alloc] init];
                [answer2 setText:@"BestOf5"];
                [answer2 setIsCorrect:YES];
                
                Answer *answer3 = [[Answer alloc] init];
                [answer3 setText:@"Double Elimination"];
                
                Answer *answer4 = [[Answer alloc] init];
                [answer4 setText:@"BestOf1"];
                
                [newQuestion setAnswers:[[NSArray arrayWithObjects:answer1, answer2, answer3, answer4, nil] mutableCopy]];
                [newQuestion setImage:[UIImage imageNamed:@"tournaments_TI1_grandfinal_qualification.jpg"]];
                break;
            }
        }
    }
    else if ([[aTheme name] isEqualToString:@"Mechanics"]) {
        NSInteger num = arc4random_uniform(2);
        switch (num) {
            case 0: {
                [newQuestion setText:@"What is the highest duration of \"Sacred Arrow\" skill?"];

                Answer *answer1 = [[Answer alloc] init];
                [answer1 setText:@"5 seconds"];
                
                Answer *answer2 = [[Answer alloc] init];
                [answer2 setText:@"3.75 seconds"];
                
                Answer *answer3 = [[Answer alloc] init];
                [answer3 setText:@"2.5 seconds"];
                
                Answer *answer4 = [[Answer alloc] init];
                [answer4 setText:@"7 seconds"];
                
                [answer1 setIsCorrect:YES];
                [newQuestion setAnswers:[[NSArray arrayWithObjects:answer1, answer2, answer3, answer4, nil] mutableCopy]];
                break;
            }
            case 1: {
                [newQuestion setText:@"Bara can run through Cogs?"];

                Answer *answer1 = [[Answer alloc] init];
                [answer1 setText:@"Yes"];
                
                Answer *answer2 = [[Answer alloc] init];
                [answer2 setText:@"No"];
                
                [answer2 setIsCorrect:YES];
                [newQuestion setAnswers:[[NSArray arrayWithObjects:answer1, answer2, nil] mutableCopy]];
                break;
            }
            case 2: {
                [newQuestion setText:@"Storm Spirit can fly through Void's Chronosphere?"];

                Answer *answer1 = [[Answer alloc] init];
                [answer1 setText:@"Yes"];
                
                Answer *answer2 = [[Answer alloc] init];
                [answer2 setText:@"No"];
                
                [answer1 setIsCorrect:YES];
                [newQuestion setAnswers:[[NSArray arrayWithObjects:answer1, answer2, nil] mutableCopy]];

                break;
            }
        }
        
    }
    
    return newQuestion;
}


@end
