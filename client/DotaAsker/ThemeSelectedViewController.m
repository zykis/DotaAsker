//
//  ThemeSelectedViewController.m
//  DotaAsker
//
//  Created by Artem on 17/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.

// Libraries
#import <ReactiveObjC/ReactiveObjC.h>

// Local
#import "ThemeSelectedViewController.h"
#import "QuestionViewController.h"
#import "ServiceLayer.h"
#import "UIViewController+Utils.h"
#import "ThemeButton.h"


@interface ThemeSelectedViewController ()

@end

@implementation ThemeSelectedViewController

@synthesize roundID = _roundID;
@synthesize selectedThemeID = _selectedThemeID;
@synthesize selectedThemeButton = _selectedThemeButton;

- (Round*)round {
    return [Round objectForPrimaryKey:@(_roundID)];
}

- (Theme*)selectedTheme {
    return [Theme objectForPrimaryKey:@(_selectedThemeID)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [_selectedThemeButton setTitle:[[self selectedTheme] name] forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showQuestions {
    [self performSegueWithIdentifier:@"showQuestions" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showQuestions"]) {
        QuestionViewController *destVC;
        id destID = (QuestionViewController*)[segue destinationViewController];
        assert([destID isKindOfClass:[QuestionViewController class]]);
        destVC = (QuestionViewController*)destID;
        [destVC setRoundID:_roundID];
        [destVC setSelectedThemeID:_selectedThemeID];
    }
}

@end
