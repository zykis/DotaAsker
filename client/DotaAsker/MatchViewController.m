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
#import "Palette.h"
#import "RoundViewLayered.h"

#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>


#define SECTION_MATCH_INFO 0
#define SECTION_ROUNDS 1
#define SECTION_ACTIONS 2
#define MINIMUM_ROUND_HEIGHT 15.0f + 27.0f + 2.0f + 6.0f

#define BUTTON_WAITING 0
#define BUTTON_PLAY 1
#define BUTTON_CONTINUE 2
#define BUTTON_SYNCHRONIZE 3
#define BUTTON_PLAY_AGAIN 4
#define BUTTON_REVENGE 5

@interface MatchViewController ()

@end

@implementation MatchViewController

@synthesize matchViewModel = _matchViewModel;
@synthesize matchID = _matchID;
@synthesize buttonState = _buttonState;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _matchViewModel = [[MatchViewModel alloc] init];
    
    bool bMatchFound = false;
    for (Match* m in [[Player instance] matches]) {
        if (m.ID == _matchID) {
            [_matchViewModel setMatchID:m.ID];
            bMatchFound = true;
            break;
        }
    }
    assert(bMatchFound);
    
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self loadBackgroundImage];
    [self loadBackgroundImage:[[Palette shared] pattern] atView:self.tableView];
    [_tableView reloadData];
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
    if ([[segue identifier] isEqualToString:@"showThemeSelection"]) {
        ThemeSelectionViewController *destVC = (ThemeSelectionViewController*) [segue destinationViewController];
        Round* selectedRound = [[[ServiceLayer instance] roundService] currentRoundforMatch:[_matchViewModel match]];
        [destVC setRoundID:selectedRound.ID];
    }
}

- (IBAction)midleButtonPushed:(id)sender {
    Round* currentRound = [[[ServiceLayer instance] roundService ] currentRoundforMatch:[_matchViewModel match]];
    User* opponent = [_matchViewModel opponent];

    switch(_buttonState)
    {
        case BUTTON_PLAY:
        {
            BOOL playerAnswering = true;
            BOOL bThemeSelected = [currentRound selectedTheme] != nil;
            for (UserAnswer* ua in [currentRound userAnswers]) {
                if ([[ua relatedUser] isEqual:opponent]) {
                    playerAnswering = NO;
                    break;
                }
            }
            if (playerAnswering && !bThemeSelected) {
                [self performSegueWithIdentifier:@"showThemeSelection" sender:sender];
            }
            else {
                [self performSegueWithIdentifier:@"showThemeSelected" sender:sender];
            }
            break;
        }
        case BUTTON_SYNCHRONIZE:
        {
            // Present LoadingView
            __block LoadingView* loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50)];
            [loadingView setMessage:@"Sending answers"];
            [[self view] addSubview:loadingView];
        
            __block BOOL obtained = YES;
            void (^nextBlock)(UserAnswer* _Nullable userAnswer) = ^void(UserAnswer* _Nullable x) {
                RLMRealm* realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                UserAnswer* _ua = [[UserAnswer objectsWhere:@"relatedRoundID == %lld AND relatedUserID == %lld AND relatedQuestionID == %lld", x.relatedRoundID, x.relatedUserID, x.relatedQuestionID] firstObject];
                _ua.synchronized = true;
                [realm commitWriteTransaction];
                obtained = YES;
            };
            void (^errorBlock)(NSError* _Nonnull error) = ^void(NSError* _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [loadingView removeFromSuperview];
                    [self.tableView reloadData];
                });
            };
            void (^completeBlock)() = ^void() {
                RACReplaySubject* subject = [[[ServiceLayer instance] userService] obtainWithAccessToken:[[[ServiceLayer instance] authorizationService] accessToken]];
                [subject subscribeNext:^(id x) {
                RLMRealm* realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                [realm addOrUpdateObject:x];
                [realm commitWriteTransaction];
                } error:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [loadingView removeFromSuperview];
                        [self.tableView reloadData];
                    });
                } completed:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [loadingView removeFromSuperview];
                        [self.tableView reloadData];
                    });
                }];
            };
        
            RLMResults<UserAnswer*>* uas = [UserAnswer objectsWhere:@"synchronized == false"];
            NSMutableArray* ar = [[NSMutableArray alloc] init];
            for (UserAnswer* ua in uas) {
                [ar addObject:[NSNumber numberWithLongLong:ua.ID]];
            }
            NSArray* arr = [NSArray arrayWithArray:ar];
            [[[ServiceLayer instance] userAnswerService] sendUserAnswers:arr next:nextBlock error:errorBlock complete:completeBlock];
            break;
        }
            
        case BUTTON_WAITING:
            assert(0); // button should be inactive
            break;
        
        case BUTTON_PLAY_AGAIN:
            [[self navigationController] popViewControllerAnimated:YES];
            break;
        case BUTTON_REVENGE:
            [[self navigationController] popViewControllerAnimated:YES];
            break;
            
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
        RACSubject* subject = [[[ServiceLayer instance] userService] obtainWithAccessToken:[[[ServiceLayer instance] authorizationService] accessToken]];
        [subject subscribeNext:^(id  _Nullable x) {
            RLMRealm* realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            [realm addOrUpdateObject:x];
            [realm commitWriteTransaction];
            [loadingView removeFromSuperview];
        } error:^(NSError * _Nullable error) {
            NSLog(@"Error updating player");
            [loadingView removeFromSuperview];
        } completed:^{
            [self.navigationController popViewControllerAnimated:YES];
            [self.tableView reloadData];
        }];
    }];
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
            RoundViewLayered* roundView = (RoundViewLayered*)[cell viewWithTag:100];
            roundView.delegate = self;
            UILabel *roundNumber = (UILabel*)[cell viewWithTag:107];
            [roundNumber setAdjustsFontSizeToFitWidth:YES];
            [roundNumber setText:[NSString stringWithFormat:@"Round # %ld",(long)[indexPath row]+1]];
            UILabel *roundStatus = (UILabel*)[cell viewWithTag:108];
            [roundStatus setText:[_matchViewModel roundStatusTextForRoundInRow:[indexPath row]]];
            [roundStatus setAdjustsFontSizeToFitWidth:YES];
            
            Round* selectedRound = [[[_matchViewModel match] rounds] objectAtIndex:[indexPath row]];
            
            RLMResults* playerUserAnswers = [[UserAnswer objectsWhere:@"relatedRoundID = %llu AND relatedUserID = %llu", selectedRound.ID, [[Player instance] ID]] sortedResultsUsingKeyPath:@"createdOn" ascending:YES];
            RLMResults* opponentUserAnswers = [[UserAnswer objectsWhere:@"relatedRoundID = %llu AND relatedUserID = %llu", selectedRound.ID, [[_matchViewModel opponent] ID]] sortedResultsUsingKeyPath:@"createdOn" ascending:YES];
            
            for (int i = 0; i < 6; i++) {
                AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:101 + i];
                answerItemView.delegate = roundView;
                [answerItemView setHidden:YES];
            }
            for (NSUInteger i = 0; i < [playerUserAnswers count]; i++) {
                UserAnswer* ua = [playerUserAnswers objectAtIndex:i];
                AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:101 + i];
                answerItemView.delegate = roundView;
                [answerItemView setHidden:NO];
                BOOL isCorrect = [[ua relatedAnswer] isCorrect];
                [answerItemView setAnswerState:isCorrect];
            }
            for (NSUInteger i = 0; i < [opponentUserAnswers count]; i++) {
                UserAnswer* ua = [opponentUserAnswers objectAtIndex:i];
                AnswerItemView *answerItemView = (AnswerItemView*)[cell viewWithTag:104 + i];
                answerItemView.delegate = roundView;
                [answerItemView setHidden:NO];
                
                if (([selectedRound isEqual:[[[ServiceLayer instance] roundService] currentRoundforMatch:[_matchViewModel match]]])
                    && ([[selectedRound nextMoveUser] isEqual:[Player instance]]) && ([playerUserAnswers count] < 3))
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

            _buttonState = [self middleButtonState];
            switch(_buttonState)
            {
                case BUTTON_PLAY:
                    [leftButton setHidden:NO];
                    [middleButton setTitle:@"Play" forState:UIControlStateNormal];
                    [middleButton setEnabled:YES];
                    break;
                case BUTTON_SYNCHRONIZE:
                    [leftButton setHidden:NO];
                    [middleButton setTitle:@"Synchronize" forState:UIControlStateNormal];
                    [middleButton setEnabled:YES];
                    break;
                case BUTTON_WAITING:
                    [leftButton setHidden:YES];
                    [middleButton setTitle:@"Waiting..." forState:UIControlStateNormal];
                    [middleButton setEnabled:NO];
                    break;
                case BUTTON_PLAY_AGAIN:
                    [leftButton setHidden:YES];
                    [middleButton setTitle:@"Play again" forState:UIControlStateNormal];
                    [middleButton setEnabled:YES];
                    break;
                case BUTTON_REVENGE:
                    [leftButton setHidden:YES];
                    [middleButton setTitle:@"Revenge" forState:UIControlStateNormal];
                    [middleButton setEnabled:YES];
                    break;
                default: assert(0);
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

- (void)roundViewAnswerWasTapped:(RoundViewLayered *)roundView atIndex:(NSInteger)index {
    //get appropriative answer
    NSIndexPath *path;
    //как получить указатель на текущий раунд?
    for (int i = 0; i < [[_tableView visibleCells] count]; i++) {
        UITableViewCell *cell = [[_tableView visibleCells] objectAtIndex:i];
        if ([[cell reuseIdentifier] isEqualToString:@"round_cell"]) {
            RoundViewLayered* visibleRoundView = (RoundViewLayered*)[cell viewWithTag:100];
            if ([visibleRoundView isEqual:roundView]) {
                //находим раунд для соотв ячейки
                path = [_tableView indexPathForCell:cell];
                break;
            }
        }
    }
    if(!path)
        return;
    
    NSString *title = [NSString stringWithFormat:@"Question %ld:", (long)index + 1];
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

- (NSUInteger)middleButtonState {
    if ([[_matchViewModel match] state] != MATCH_RUNNING){
        if([_matchViewModel playerScore] < [_matchViewModel opponentScore]) {
            return BUTTON_REVENGE;
        }
        else {
            return BUTTON_PLAY_AGAIN;
        }
    }
    else if([[_matchViewModel nextMoveUser] isEqual:[Player instance]]) {
        // If last 3 UserAnswers synchronized, play
        // else, answer estimated questions
        NSUInteger unsynchronizedCount = 0;
        NSUInteger totalCount = 0;
        for (UserAnswer* ua in [_matchViewModel lastPlayerUserAnswers]) {
            totalCount++;
            if (![ua synchronized]) {
                unsynchronizedCount++;
            }
        }
        if ((unsynchronizedCount > 0) && (unsynchronizedCount <= 3)) {
            return BUTTON_SYNCHRONIZE;
        }
        else if((unsynchronizedCount == 0) && (totalCount == 0)) {
            return BUTTON_PLAY;
        } else {
            NSLog(@"Can't define round state. Crushing app");
            NSLog(@"Total UAs: %ld\nUnsynchronized UAs: %ld", totalCount, unsynchronizedCount);
            assert(0);
        }
    }
    else {
        return BUTTON_WAITING;
    }
}

@end
















