//
//  ThemeSelectedViewController.m
//  DotaAsker
//
//  Created by Artem on 17/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "ThemeSelectedViewController.h"
#import "QuestionViewController.h"
#import "ServiceLayer.h"

@interface ThemeSelectedViewController ()

@end

@implementation ThemeSelectedViewController

@synthesize themeImageView = _themeImageView;
@synthesize match = _match;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage:[[[ServiceLayer instance] userService] wallpapersDefault]];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showQuestions)];
    [_themeImageView addGestureRecognizer:tapGesture];
    
    if (_match) {
        UIImage* themeImage = [[[ServiceLayer instance] matchService] currentRoundThemeImageForMatch:_match];
        [_themeImageView setImage:themeImage];
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
        
        Round* currentRound = [[[ServiceLayer instance] roundService] currentRoundforMatch:_match];
        
        //GENERATING QUESTIONS
        if (([currentRound round_state] == ROUND_PLAYER_ASWERING)) {
            Theme* theme = [[[ServiceLayer instance] themeService] obtain:[currentRound themeID]];
            NSArray* questions = [[[ServiceLayer instance]  questionService] generateQuestionsOnTheme:theme];
            [[[ServiceLayer instance] roundService] setQuestions:questions forRound:currentRound];
            [[[ServiceLayer instance] roundService] update:currentRound];
        }
        
        //send RoundQuestions message!!!
        
        [destVC setRound:currentRound];
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
