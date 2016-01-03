//
//  ThemeSelectedViewController.m
//  DotaAsker
//
//  Created by Artem on 17/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "ThemeSelectedViewController.h"
#import "Match.h"
#import "QuestionViewController.h"
#import "Database.h"

@interface ThemeSelectedViewController ()

@end

@implementation ThemeSelectedViewController

@synthesize themeImageView = _themeImageView;
@synthesize match = _match;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showQuestions)];
    [_themeImageView addGestureRecognizer:tapGesture];
    
    if (_match) {
        Theme *theme = [[_match currentRound] theme];
        [_themeImageView setImage:[theme image]];
        [_themeImageView setContentMode:UIViewContentModeScaleAspectFill];
    }
    else {
        NSLog(@"Can't get theme");
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showQuestions {
    [self performSegueWithIdentifier:@"showQuestions" sender:_themeImageView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showQuestions"]) {
        QuestionViewController *destVC;
        id destID = (QuestionViewController*)[segue destinationViewController];
        if (![destID isKindOfClass:[QuestionViewController class]]) {
            NSLog(@"ThemeSelectedVoewController::prepareForSegue(): destination viewController is not a member of class QuestionViewController.");
            return;
        }
        else {
            destVC = (QuestionViewController*)destID;
        }
        
        Round* currentRound = [_match currentRound];
        
        //GENERATING QUESTIONS
        if (([currentRound round_state] == ROUND_PLAYER_ASWERING)) {
            [currentRound setQuestions:[[Database instance] generateQuestionsOnTheme:[currentRound theme]]];
        }
        
        //send RoundQuestions message!!!
        
        
        [destVC setRound:[_match currentRound]];
        [destVC setMatch:_match];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
