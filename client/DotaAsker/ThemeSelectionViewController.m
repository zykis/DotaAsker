//
//  ThemeSelectionViewController.m
//  DotaAsker
//
//  Created by Artem on 14/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

// Local
#import "ThemeSelectionViewController.h"
#import "ThemeSelectedViewController.h"
#import "ServiceLayer.h"
#import "UIViewController+Utils.h"
#import "ThemeButton.h"

// Libraries
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>


@interface ThemeSelectionViewController ()

@end

@implementation ThemeSelectionViewController

@synthesize imagedButton1 = _imagedButton1;
@synthesize imagedButton2 = _imagedButton2;
@synthesize imagedButton3 = _imagedButton3;
@synthesize roundID = _roundID;

- (Round*)round {
    return [Round objectForPrimaryKey:@(_roundID)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    NSArray* themes = [[[ServiceLayer instance] roundService] themesForRound:[self round]];
    assert([themes count] == 3);
    Theme* theme1 = [themes objectAtIndex:0];
    Theme* theme2 = [themes objectAtIndex:1];
    Theme* theme3 = [themes objectAtIndex:2];
    
    [_imagedButton1 setTitle:[theme1 name] forState:UIControlStateNormal];
    [_imagedButton2 setTitle:[theme2 name] forState:UIControlStateNormal];
    [_imagedButton3 setTitle:[theme3 name] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"themeSelected"]) {
        ThemeSelectedViewController *destVC = (ThemeSelectedViewController*)[segue destinationViewController];
        NSArray* themes = [[[ServiceLayer instance] roundService] themesForRound:[self round]];
        Theme* selectedTheme;
        if ([sender isEqual:_imagedButton1]) {
            selectedTheme = [themes objectAtIndex:0];
        }
        else if([sender isEqual:_imagedButton2]) {
            selectedTheme = [themes objectAtIndex:1];
        }
        else if([sender isEqual:_imagedButton3]) {
            selectedTheme = [themes objectAtIndex:2];
        }
        
        Round* round = [Round objectForPrimaryKey:@(_roundID)];
        // Updating round's selected theme
        LoadingView* loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50)];
        [loadingView setMessage:@"Updating round"];
        [[self view] addSubview:loadingView];
        
        RACReplaySubject* subject = [[[ServiceLayer instance] roundService] update:round];
        [subject subscribeError:^(NSError *error) {
            [loadingView removeFromSuperview];
            [self presentAlertControllerWithTitle:@"Round not updated" andMessage:@"Check out connection and try again, please"];
        } completed:^{
            // Persist selected theme
            RLMRealm* realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            [round setSelectedTheme: selectedTheme];
            [realm commitWriteTransaction];
            
            assert(selectedTheme);
            [destVC setRoundID:_roundID];
            [destVC setSelectedThemeID:selectedTheme.ID];
            
            [loadingView removeFromSuperview];
        }];
    }
}


#pragma mark - Navigation

- (IBAction)button1Pressed:(id)sender {
    [self performSegueWithIdentifier:@"themeSelected" sender:sender];
}

- (IBAction)button2Pressed:(id)sender {
    [self performSegueWithIdentifier:@"themeSelected" sender:sender];
}

- (IBAction)button3Pressed:(id)sender {
    [self performSegueWithIdentifier:@"themeSelected" sender:sender];
}
@end
