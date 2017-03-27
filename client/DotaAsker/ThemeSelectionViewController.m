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
#import "ModalLoadingView.h"

// Libraries
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>


@interface ThemeSelectionViewController ()

@end

@implementation ThemeSelectionViewController

@synthesize imagedButton1 = _imagedButton1;
@synthesize imagedButton2 = _imagedButton2;
@synthesize imagedButton3 = _imagedButton3;
@synthesize roundID = _roundID;

- (void)blockUI {
    [_imagedButton1 setEnabled:NO];
    [_imagedButton2 setEnabled:NO];
    [_imagedButton3 setEnabled:NO];
}

- (void)unblockUI {
    [_imagedButton1 setEnabled:YES];
    [_imagedButton2 setEnabled:YES];
    [_imagedButton3 setEnabled:YES];
}

- (Round*)round {
    return [Round objectForPrimaryKey:@(_roundID)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self unblockUI];
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

- (void)updateRoundSelectedTheme:(Theme*)theme {
    Round* round = [Round objectForPrimaryKey:@(_roundID)];
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [round setSelectedTheme: theme];
    [round setModified:YES];
    [realm commitWriteTransaction];
    [self performSegueWithIdentifier:@"themeSelected" sender:theme];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"themeSelected"]) {
        ThemeSelectedViewController *destVC = (ThemeSelectedViewController*)[segue destinationViewController];
        Theme* selectedTheme = sender;
        
        assert(selectedTheme);
        [destVC setRoundID:_roundID];
        [destVC setSelectedThemeID:selectedTheme.ID];
    }
}


#pragma mark - Navigation

- (IBAction)button1Pressed:(id)sender {
    NSArray* themes = [[[ServiceLayer instance] roundService] themesForRound:[self round]];
    [self updateRoundSelectedTheme:[themes objectAtIndex:0]];
    [self blockUI];
}

- (IBAction)button2Pressed:(id)sender {
    NSArray* themes = [[[ServiceLayer instance] roundService] themesForRound:[self round]];
    [self updateRoundSelectedTheme:[themes objectAtIndex:1]];
    [self blockUI];
}

- (IBAction)button3Pressed:(id)sender {
    NSArray* themes = [[[ServiceLayer instance] roundService] themesForRound:[self round]];
    [self updateRoundSelectedTheme:[themes objectAtIndex:2]];
    [self blockUI];
}
@end
