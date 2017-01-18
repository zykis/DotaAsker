//
//  ThemeSelectedViewController.m
//  DotaAsker
//
//  Created by Artem on 17/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

// Libraries
#import <ReactiveObjC/ReactiveObjC.h>

#import "ThemeSelectedViewController.h"
#import "QuestionViewController.h"
#import "ServiceLayer.h"

@interface ThemeSelectedViewController ()

@end

@implementation ThemeSelectedViewController

@synthesize themeImageView = _themeImageView;
@synthesize round = _round;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Getting objects from Realm
    _round = [Round objectForPrimaryKey: [NSNumber numberWithLongLong: self.roundID]];
    _selectedTheme = [Theme objectForPrimaryKey: [NSNumber numberWithLongLong:self.selectedThemeID]];
    
    // Setting selected theme for Round
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [_round setSelectedTheme:_selectedTheme];
    [realm commitWriteTransaction];
    
    // Sending to server
    LoadingView* loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50)];
    [loadingView setMessage:@"Updating round"];
    [[self view] addSubview:loadingView];
    
    RACReplaySubject* subject = [[[ServiceLayer instance] roundService] update:_round];
    [subject subscribeError:^(NSError *error) {
        [self presentAlertControllerWithTitle:@"Round not updated" andMessage:@"Check out connection and try again, please"];
        [loadingView removeFromSuperview];
    } completed:^{
        [loadingView removeFromSuperview];
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showQuestions)];
    [_themeImageView addGestureRecognizer:tapGesture];
    
    UIImage* themeImage = [UIImage imageNamed:[_selectedTheme imageName]];
    [_themeImageView setImage:themeImage];
    [_themeImageView setContentMode:UIViewContentModeScaleAspectFill];
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
        assert([destID isKindOfClass:[QuestionViewController class]]);
        destVC = (QuestionViewController*)destID;
        [destVC setRoundID:_round.ID];
        [destVC setSelectedThemeID:_selectedTheme.ID];
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
