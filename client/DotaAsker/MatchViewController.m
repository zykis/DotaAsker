//
//  MatchInfoViewController.m
//  DotaAsker
//
//  Created by Artem on 25/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "MatchViewController.h"
#import "TableViewCell.h"
#import "ThemeSelectedViewController.h"
#import "ThemeSelectionViewController.h"
#import "Player.h"
#import "MatchViewModel.h"
#import "ServiceLayer.h"
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>


#define SECTION_MATCH_INFO 0
#define SECTION_ROUNDS 1
#define SECTION_ACTIONS 2
#define MINIMUM_ROUND_HEIGHT 15.0f + 27.0f + 2.0f + 6.0f

@interface MatchViewController ()

@end

@implementation MatchViewController

@synthesize matchViewModel = _matchViewModel;
@synthesize matchID = _matchID;

- (void)viewDidLoad {
    [super viewDidLoad];
    _matchViewModel = [[MatchViewModel alloc] init];
    
    bool bMatchFound = false;
    for (Match* m in [[Player instance] matches]) {
        if (m.ID == _matchID) {
            [_matchViewModel setMatch:m];
            bMatchFound = true;
            break;
        }
    }
    assert(bMatchFound);
    
    
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
        Round* selectedRound = [[[ServiceLayer instance] roundService] currentRoundforMatch:[_matchViewModel match]];
        Theme* selectedTheme = [[[ServiceLayer instance] roundService] themeSelectedForRound:selectedRound];
        // If no selected theme in round, try to update it
        [destVC setRound:selectedRound];
        [destVC setSelectedTheme:selectedTheme];
    }
    else if ([[segue identifier] isEqualToString:@"showThemeSelection"]) {
        ThemeSelectionViewController *destVC = (ThemeSelectionViewController*) [segue destinationViewController];
        [destVC setRound:[[[ServiceLayer instance] roundService] currentRoundforMatch:[_matchViewModel match]]];
    }
}

- (IBAction)midleButtonPushed:(id)sender {
    if ([[_matchViewModel match] state] == MATCH_RUNNING) {
        if ([[_matchViewModel nextMoveUser] isEqual:[Player instance]]) {
            // Answering or Replying?
            Round* currentRound = [[[ServiceLayer instance] roundService ] currentRoundforMatch:[_matchViewModel match]];
            User* opponent = [_matchViewModel opponent];
            RLMResults<UserAnswer*>* lastPlayerUserAnswers = [_matchViewModel lastPlayerUserAnswers];
            
            NSUInteger unsynchronized_count = 0;
            for (UserAnswer* ua in lastPlayerUserAnswers) {
                if (![ua synchronized]) {
                    unsynchronized_count++;
                }
            }
            
            if (unsynchronized_count > 0) {
                if ([lastPlayerUserAnswers count] > unsynchronized_count) {
                    // If not all question are answered
                    // Continue answering questions
                    
                    //! TODO: Set current_question_index in destVC
                    [self performSegueWithIdentifier:@"showQuestions" sender:sender];
                }
                else {
                    NSMutableArray* unsynchronizedUserAnswers = [[NSMutableArray alloc] init];
                    for (UserAnswer* ua in lastPlayerUserAnswers) {
                        if (![ua synchronized]) {
                            [unsynchronizedUserAnswers addObject:ua];
                        }
                    }
                    NSMutableArray* signalsArray = [[NSMutableArray alloc] init];
                    for (UserAnswer* ua in [_matchViewModel lastPlayerUserAnswers]) {
                        RACSignal* signal = [[[ServiceLayer instance] userAnswerService] create:ua];
                        [signalsArray addObject:signal];
                    }
                    
                    RACSignal *sig = [RACSignal concat:[signalsArray.rac_sequence map:^id(id value) {
                        return value;
                    }]];
                    
                    [sig subscribeNext:^(id x) {
                        // Mark userAnswer as synchronized
                        for (UserAnswer* ua in [[[[ServiceLayer instance] roundService] currentRoundforMatch:[_matchViewModel match]] userAnswers]) {
                            if ([ua isEqual:x]) {
                                ua.synchronized = true;
                                NSLog(@"Answer synchronized");
                            }
                        }
                    } error:^(NSError *error) {
                        NSLog(@"Error udpating ua");
                        [self.tableView reloadData];
                    } completed:^{
                        RACReplaySubject* subject = [[[ServiceLayer instance] userService] obtainWithAccessToken:[[[ServiceLayer instance] authorizationService] accessToken]];
                        [subject subscribeNext:^(id x) {
                            [Player setPlayer:x];
                        } error:^(NSError *error) {
                            [self.tableView reloadData];
                        } completed:^{
                            for (Match* m in [[Player instance] matches]) {
                                if ([m isEqual:[_matchViewModel match]]) {
                                    [_matchViewModel setMatch:m];
                                    [self.tableView reloadData];
                                    break;
                                }
                            }
                        }];
                    }];
                }
            }
            
            // Answer or Reply
            else {
                BOOL playerAnswering = true;
                for (UserAnswer* ua in [currentRound userAnswers]) {
                    if ([[ua relatedUser] isEqual:opponent]) {
                        playerAnswering = NO; // Player replying
                        break;
                    }
                }
                if (playerAnswering) {
                    [self performSegueWithIdentifier:@"showThemeSelection" sender:sender];
                }
                else {
                    [self performSegueWithIdentifier:@"showThemeSelected" sender:sender];
                }
            }
        }
        else {
            // waiting button
        }
    }
    else {
        //Revenge button
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (IBAction)sendFriendRequest:(id)sender {
    LoadingView* loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50)];
    [loadingView setMessage:@"Sending request"];
    [[self view] addSubview:loadingView];
    
    RACReplaySubject* subject = [[[ServiceLayer instance] userService] sendFriendRequestToUser:[_matchViewModel opponent]];
    [subject subscribeError:^(NSError *error) {
        [loadingView removeFromSuperview];
        [self presentAlertControllerWithTitle:@"Error adding a friend" andMessage:[error localizedDescription]];
    } completed:^{
        [loadingView removeFromSuperview];
    }];
}

- (IBAction)surrend:(id)sender {
    LoadingView* loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50)];
    [loadingView setMessage:@"Surrending"];
    [[self view] addSubview:loadingView];
    
    RACReplaySubject* subject = [[[ServiceLayer instance] matchService] surrendAtMatch:[_matchViewModel match]];
    [subject subscribeError:^(NSError *error) {
        [loadingView removeFromSuperview];
        [self presentAlertControllerWithTitle:@"Can't surrend" andMessage:[error localizedDescription]];
    } completed:^{
        [loadingView removeFromSuperview];
    }];
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
        case SECTION_ROUNDS:
            return ROUNDS_IN_MATCH;
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
            [firstPlayerImageView setImage:[UIImage imageNamed:[[Player instance] avatarImageName]]];
            
            UILabel *firstPlayerNameLabel = (UILabel*)[cell viewWithTag:101];
            [firstPlayerNameLabel setText:[[Player instance] name]];
            
            //filling 2nd player data
            UIImageView *secondPlayerImageView = (UIImageView*)[cell viewWithTag:102];
            [secondPlayerImageView setImage:[UIImage imageNamed:[[_matchViewModel opponent] avatarImageName]]];
            UILabel *secondPlayerNameLabel = (UILabel*)[cell viewWithTag:103];
            [secondPlayerNameLabel setText:[[_matchViewModel opponent] name]];
            
            //filling score
            UILabel *scoreLabel = (UILabel*)[cell viewWithTag:104];
            NSString *scoreText = [NSString stringWithFormat:@"%ld   -   %ld",
                                   (long)[_matchViewModel playerScore], (long)[_matchViewModel opponentScore]];
            [scoreLabel setText:scoreText];
            break;
        }
            
        case SECTION_ROUNDS: {
            cell = [tableView dequeueReusableCellWithIdentifier:roundCellIdentifier];

            RoundView *roundView = (RoundView*)[cell viewWithTag:100];
            roundView.delegate = self;
            UILabel *roundNumber = (UILabel*)[cell viewWithTag:107];
            [roundNumber setAdjustsFontSizeToFitWidth:YES];
            [roundNumber setText:[NSString stringWithFormat:@"Round # %ld",[indexPath row]+1]];
            UILabel *roundStatus = (UILabel*)[cell viewWithTag:108];
            [roundStatus setText:[_matchViewModel roundStatusTextForRoundInRow:[indexPath row]]];
            [roundStatus setAdjustsFontSizeToFitWidth:YES];
            
            Round* selectedRound = [[[_matchViewModel match] rounds] objectAtIndex:[indexPath row]];
            NSMutableArray* playerAnswers = [[NSMutableArray alloc] init];
            NSMutableArray* opponentAnswers = [[NSMutableArray alloc] init];
            for (UserAnswer* ua in [selectedRound userAnswers]) {
                if ([[ua relatedUser] isEqual:[Player instance]]) {
                    [playerAnswers addObject:ua];
                }
                else {
                    [opponentAnswers addObject:ua];
                }
            }
            
            for (int i = 0; i < 6; i++) {
                AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:101 + i];
                answerItemView.delegate = roundView;
                [answerItemView setHidden:YES];
            }
            for (NSUInteger i = 0; i < [playerAnswers count]; i++) {
                UserAnswer* ua = [playerAnswers objectAtIndex:i];
                AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:101 + i];
                answerItemView.delegate = roundView;
                [answerItemView setHidden:NO];
                
                [answerItemView setAnswerState:[[ua relatedAnswer] isCorrect]];
            }
            for (NSUInteger i = 0; i < [opponentAnswers count]; i++) {
                UserAnswer* ua = [opponentAnswers objectAtIndex:i];
                AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:104 + i];
                answerItemView.delegate = roundView;
                [answerItemView setHidden:NO];
                
                if (([selectedRound isEqual:[[[ServiceLayer instance] roundService] currentRoundforMatch:[_matchViewModel match]]])
                    && ([[selectedRound nextMoveUser] isEqual:[Player instance]]) && ([playerAnswers count] < 3))
                    [answerItemView setAnswerState:2];
                else
                    [answerItemView setAnswerState:[[ua relatedAnswer] isCorrect]];
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

            if ([[_matchViewModel match] state] != MATCH_RUNNING){
                if([_matchViewModel playerScore] < [_matchViewModel opponentScore]) {
                    [leftButton setHidden:YES];
                    [middleButton setTitle:@"Revenge" forState:UIControlStateNormal];
                    [middleButton setEnabled:YES];
                }
                else {
                    [leftButton setHidden:YES];
                    [middleButton setTitle:@"Play again" forState:UIControlStateNormal];
                    [middleButton setEnabled:YES];
                }
            }
            else if([[_matchViewModel nextMoveUser] isEqual:[Player instance]]) {
                // If last 3 UserAnswers synchronized, play
                // else, answer estimated questions
                NSUInteger unsynchronizedCount = 0;
                for (UserAnswer* ua in [_matchViewModel lastPlayerUserAnswers]) {
                    if (![ua synchronized]) {
                        unsynchronizedCount++;
                    }
                }
                if ((unsynchronizedCount > 0) && (unsynchronizedCount < 3)) {
                    [leftButton setHidden:NO];
                    [middleButton setTitle:@"Continue" forState:UIControlStateNormal];
                    [middleButton setEnabled:YES];
                }
                else if (unsynchronizedCount == 3) {
                    [leftButton setHidden:NO];
                    [middleButton setTitle:@"Synchronize" forState:UIControlStateNormal];
                    [middleButton setEnabled:YES];
                }
                else {
                    [leftButton setHidden:NO];
                    [middleButton setTitle:@"Play" forState:UIControlStateNormal];
                    [middleButton setEnabled:YES];
                }
            }
            else {
                [leftButton setHidden:YES];
                [middleButton setTitle:@"Waiting..." forState:UIControlStateNormal];
                [middleButton setEnabled:NO];
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
    
    NSString *title = [NSString stringWithFormat:@"Question %ld:", index + 1];
    NSString *text = [_matchViewModel textForUserAnswerForRoundInRow:[path row] andUserAnswerIndex:index];

    
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
















