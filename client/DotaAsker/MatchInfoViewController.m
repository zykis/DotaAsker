//
//  MatchInfoViewController.m
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "MatchInfoViewController.h"
#import "Player.h"
#import "Round.h"
#import "RoundView.h"
#import "UserAnswer.h"
#import "Question.h"
#import "UserAnswer.h"
#import "TableViewCell.h"
#import "ThemeSelectedViewController.h"
#import "ThemeSelectionViewController.h"
#import "Answer.h"

#define SECTION_MATCH_INFO 0
#define SECTION_ROUNDS 1
#define SECTION_ACTIONS 2
#define MINIMUM_ROUND_HEIGHT 15.0f + 27.0f + 2.0f + 6.0f

@interface MatchInfoViewController ()

@end

@implementation MatchInfoViewController

@synthesize match = _match;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self setTableBackgroundImage:[UIImage imageNamed:@"pattern_640x1136.png"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tableView reloadData];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (IBAction)backButtonPushed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showThemeSelected"]) {
        ThemeSelectedViewController *destVC = (ThemeSelectedViewController*)[segue destinationViewController];
        [destVC setMatch:_match];
    }
    else if ([[segue identifier] isEqualToString:@"showThemeSelection"]) {
        ThemeSelectionViewController *destVC = (ThemeSelectionViewController*) [segue destinationViewController];
        [destVC setMatch:_match];
    }
}

- (IBAction)midleButtonPushed:(id)sender {
    if ([_match state] == MATCH_RUNNING) {
        //Play button
        Round *currentRound = [_match currentRound];
        if ([currentRound round_state] == ROUND_PLAYER_REPLYING) {
            [self performSegueWithIdentifier:@"showThemeSelected" sender:sender];
        }
        else if ([currentRound round_state] == ROUND_PLAYER_ASWERING) {
            [self performSegueWithIdentifier:@"showThemeSelection" sender:sender];
        }
        else {
            NSLog(@"current Round state is undefined");
        }
    }
    else {
        //Revenge button
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

#pragma mark - VusialAppearence
- (void)setBackgroundImage:(UIImage *)backgroundImage {
    UIGraphicsBeginImageContext(self.view.frame.size);
    [backgroundImage drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SECTION_MATCH_INFO:
            return 1;
        case SECTION_ROUNDS: {
            return [[_match rounds] count];
        }
        case SECTION_ACTIONS:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *matchInfoCellIdentifier = @"match_info_cell";
    static NSString *roundCellIdentifier = @"round_cell";
    static NSString *actionsCellIdentifier = @"actions_cell";
    
    UITableViewCell* cell;
    switch ([indexPath section]) {
        case SECTION_MATCH_INFO: {
            cell = [tableView dequeueReusableCellWithIdentifier:matchInfoCellIdentifier];
            
            //filling 1st player data
            UIImageView *firstPlayerImageView = (UIImageView*)[cell viewWithTag:100];
            [firstPlayerImageView setImage:[[Player instance] avatar]];
            UILabel *firstPlayerNameLabel = (UILabel*)[cell viewWithTag:101];
            [firstPlayerNameLabel setText:[[Player instance] name]];
            
            //filling 2nd player data
            UIImageView *secondPlayerImageView = (UIImageView*)[cell viewWithTag:102];
            [secondPlayerImageView setImage:[[_match opponent] avatar]];
            UILabel *secondPlayerNameLabel = (UILabel*)[cell viewWithTag:103];
            [secondPlayerNameLabel setText:[[_match opponent] name]];
            
            //filling score
            UILabel *scoreLabel = (UILabel*)[cell viewWithTag:104];
            NSString *scoreText = [NSString stringWithFormat:@"%ld   -   %ld",
                                   (long)[_match scorePlayer], [_match scoreOpponent]];
            [scoreLabel setText:scoreText];
            break;
        }
            
        case SECTION_ROUNDS: {
            cell = [tableView dequeueReusableCellWithIdentifier:roundCellIdentifier];

            Round *round = [[_match rounds] objectAtIndex:[indexPath row]];
            RoundView *roundView = (RoundView*)[cell viewWithTag:100];
            roundView.delegate = self;
            UILabel *roundNumber = (UILabel*)[cell viewWithTag:107];
            [roundNumber setAdjustsFontSizeToFitWidth:YES];
            [roundNumber setText:[NSString stringWithFormat:@"Round # %ld",[indexPath row]+1]];
            UILabel *roundStatus = (UILabel*)[cell viewWithTag:108];
            [roundStatus setAdjustsFontSizeToFitWidth:YES];
            
            switch ([round round_state]) {
                case ROUND_FINISHED: {
                    for (int i = 0; i < 3; i++) {
                        AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:101+i];
                        answerItemView.delegate = roundView;
                        [answerItemView setHidden:NO];
                        UserAnswer * answer = (UserAnswer*)[[round answersPlayer] objectAtIndex:i];
                        [answerItemView setAnswerState:[[answer relatedAnswer] isCorrect]];
                    }
                    for (int i = 0; i < 3; i++) {
                        AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:104+i];
                        answerItemView.delegate = roundView;
                        [answerItemView setHidden:NO];
                        UserAnswer * answer = (UserAnswer*)[[round answersOpponent] objectAtIndex:i];
                        [answerItemView setAnswerState:[[answer relatedAnswer] isCorrect]];
                    }
                    [roundStatus setText:@"Round finished"];
                    break;
                }
                    
                case ROUND_NOT_STARTED: {
                    for (int i = 0; i < 3; i++) {
                        AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:101+i];
                        [answerItemView setHidden:YES];
                    }
                    for (int i = 0; i < 3; i++) {
                        AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:104+i];
                        [answerItemView setHidden:YES];
                    }
                    [roundStatus setText:@"Round not started"];
                    break;
                }
                    
                case ROUND_TIME_ELAPSED: {
                    for (int i = 0; i < 3; i++) {
                        AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:101+i];
                        [answerItemView setHidden:YES];
                    }
                    for (int i = 0; i < 3; i++) {
                        AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:104+i];
                        [answerItemView setHidden:YES];
                    }
                    [roundStatus setText:@"Time Elapsed"];
                    break;
                }
                    
                case ROUND_PLAYER_ASWERING: {
                    for (int i = 0; i < 3; i++) {
                        AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:101+i];
                        [answerItemView setHidden:YES];
                    }
                    for (int i = 0; i < 3; i++) {
                        AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:104+i];
                        [answerItemView setHidden:YES];
                    }
                    [roundStatus setText:@"You answering"];
                    break;
                }
                    
                case ROUND_PLAYER_REPLYING: {
                    for (int i = 0; i < 3; i++) {
                        AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:101+i];
                        [answerItemView setHidden:YES];
                    }
                    for (int i = 0; i < 3; i++) {
                        AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:104+i];
                        [answerItemView setHidden:NO];
                        [answerItemView setAnswerState:3];
                    }
                    [roundStatus setText:@"You replying"];
                    break;
                }
                    
                case ROUND_OPPONENT_ANSWERING: {
                    for (int i = 0; i < 3; i++) {
                        AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:101+i];
                        [answerItemView setHidden:YES];
                    }
                    for (int i = 0; i < 3; i++) {
                        AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:104+i];
                        [answerItemView setHidden:YES];
                    }
                    [roundStatus setText:@"Opponent answering"];
                    break;
                }
                    
                case ROUND_OPPONENT_REPLYING: {
                    for (int i = 0; i < 3; i++) {
                        AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:101+i];
                        [answerItemView setHidden:NO];
                        if ([[round answersPlayer] count] < 3) {
                            NSLog(@"Player answers count < 3 in round with state = ROUND_OPPONENT_REPLYING");
                            return nil;
                        }
                        UserAnswer* answer = (UserAnswer*)[[round answersPlayer] objectAtIndex:i];
                        [answerItemView setAnswerState:[[answer relatedAnswer] isCorrect]];
                        
                    }
                    for (int i = 0; i < 3; i++) {
                        AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:104+i];
                        [answerItemView setHidden:YES];
                    }
                    [roundStatus setText:@"Opponent replying"];
                    break;
                }

                default:
                    break;
            }
            
            break;
        }
            
        case SECTION_ACTIONS: {
            cell = [tableView dequeueReusableCellWithIdentifier:actionsCellIdentifier];
            UIButton *leftButton = (UIButton*)[cell viewWithTag:100];
            UIButton *middleButton = (UIButton*)[cell viewWithTag:101];
            //в зависимости от состояния текущего раунда выставляем соотвутствующие кнопки
            //конец матча - это когда текущий раунд в состоянии Finished
            //и текущий раунд - последний
            Round *currentRound = [_match currentRound];

            if (([currentRound round_state] == ROUND_TIME_ELAPSED) ||
                ([currentRound round_state] == ROUND_FINISHED)) {
                
                [leftButton setHidden:YES];
                [middleButton setTitle:@"Revenge" forState:UIControlStateNormal];
                [middleButton setEnabled:YES];
            }
            else if(([currentRound round_state] == ROUND_PLAYER_ASWERING)
                    || ([currentRound round_state] == ROUND_PLAYER_REPLYING)) {
                [leftButton setHidden:NO];
                [middleButton setTitle:@"Play" forState:UIControlStateNormal];
                [middleButton setEnabled:YES];
            }
            else if (([currentRound round_state] == ROUND_OPPONENT_ANSWERING)
                     || ([currentRound round_state] == ROUND_OPPONENT_REPLYING)) {
                [leftButton setHidden:YES];
                [middleButton setTitle:@"Waiting..." forState:UIControlStateNormal];
                [middleButton setEnabled:NO];
            }
            else {
                NSLog(@"Error in MatchInfoViewController. Middlebutton capture is undefined");
            }
            break;
        }
            
        default:
            break;
    }
    
    //making transparency
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        case SECTION_MATCH_INFO:
            return 110.0f;
            
        case SECTION_ROUNDS: {
            CGFloat height = [_tableView frame].size.height;
            height -= 110.0f;
            height -= 59.0f;
            height /= 6.0;
            height /= 2.0;
            return MAX(MINIMUM_ROUND_HEIGHT, height);
        }
            
        case SECTION_ACTIONS:
            return 59.0f;
    }
    return UITableViewAutomaticDimension;
}


- (void)setTableBackgroundImage:(UIImage *)backgroundImage {
    UIGraphicsBeginImageContext(self.tableView.frame.size);
    [backgroundImage drawInRect:self.tableView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (void)roundViewAnswerWasTapped:(RoundView *)roundView atIndex:(NSInteger)index {
    //get appropriative answer
    NSIndexPath *path;
    //как получить указатель на текущий раунд?
    for (int i = 0; i < [[_tableView visibleCells] count]; i++) {
        UITableViewCell *cell = [[_tableView visibleCells] objectAtIndex:i];
        if ([[cell reuseIdentifier] isEqualToString:@"round_cell"]) {
            RoundView* visibleRoundView = (RoundView*)[cell viewWithTag:100];
            if ([visibleRoundView isEqual:roundView]) {
                //находим раунд для соотв ячейки
                path = [_tableView indexPathForCell:cell];
                break;
            }
        }
    }
    if(!path)
        return;
    
    Round *selectedRound = [_match.rounds objectAtIndex:[path row]];
    Question *selectedQuestion = [selectedRound.questions objectAtIndex:index];
    NSString *title = [NSString stringWithFormat:@"Question %ld:", index + 1];
    NSString *text;
    
    switch ([selectedRound round_state]) {
        case ROUND_FINISHED: {
            NSString *answeredTextFirstPlayer = (NSString*)
            [[[selectedRound.answersPlayer objectAtIndex: index] relatedAnswer] text];
            
            NSString *answeredTextSecondPlayer = (NSString*)
            [[[selectedRound.answersOpponent objectAtIndex: index] relatedAnswer] text];
            
            Answer *correctAnswer;
            for (Answer *ans in selectedQuestion.answers) {
                if ([ans isCorrect]) {
                    correctAnswer = ans;
                }
            }
            
            if (correctAnswer) {
                text = [NSString stringWithFormat:
                        @"%@\n\n"
                        "%@: %@\n"
                        "%@: %@\n"
                        "Right: %@"
                        , selectedQuestion.text,
                        [[Player instance] name],
                        answeredTextFirstPlayer,
                        _match.opponent.name,
                        answeredTextSecondPlayer,
                        [correctAnswer text]
                        ];
            }
        }
        break;
        case ROUND_OPPONENT_REPLYING: {
            NSString *answeredTextFirstPlayer = (NSString*)
            [[[selectedRound.answersPlayer objectAtIndex: index] relatedAnswer] text];
            
            Answer *correctAnswer;
            for (Answer *ans in selectedQuestion.answers) {
                if ([ans isCorrect]) {
                    correctAnswer = ans;
                }
            }
            
            if (correctAnswer) {
                text = [NSString stringWithFormat:
                        @"%@\n\n"
                        "%@: %@\n"
                        "Right: %@"
                        , selectedQuestion.text,
                        [[Player instance] name],
                        answeredTextFirstPlayer,
                        [correctAnswer text]
                        ];
            }
        }
        break;
            
        case ROUND_PLAYER_REPLYING: {
            text = [NSString stringWithFormat:@"Hidden"];
        }
        break;
            
        default:
        text = nil;
    }
    
    if (text) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:
                          ^(UIAlertAction* action){
                          }
                          ]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
















