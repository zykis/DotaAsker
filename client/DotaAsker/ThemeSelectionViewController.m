//
//  ThemeSelectionViewController.m
//  DotaAsker
//
//  Created by Artem on 14/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "ThemeSelectionViewController.h"
#import "ThemeSelectedViewController.h"
#import "ServiceLayer.h"
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

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray* themes = [[[ServiceLayer instance] roundService] themesForRound:[self round]];
    assert([themes count] == 3);
    
    [_imagedButton1 setImage: [UIImage imageNamed:[[themes objectAtIndex:0] imageName]] forState:UIControlStateNormal];
    [[_imagedButton1 imageView] setContentMode:UIViewContentModeScaleAspectFill];
    
    [_imagedButton2 setImage: [UIImage imageNamed:[[themes objectAtIndex:1] imageName]] forState:UIControlStateNormal];
    [[_imagedButton2 imageView] setContentMode:UIViewContentModeScaleAspectFill];
    
    [_imagedButton3 setImage: [UIImage imageNamed:[[themes objectAtIndex:2] imageName]] forState:UIControlStateNormal];
    [[_imagedButton3 imageView] setContentMode:UIViewContentModeScaleAspectFill];
    
    // Do any additional setup after loading the view.
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
        
        // Persist selected theme
        Round* round = [Round objectForPrimaryKey:@(_roundID)];
        RLMRealm* realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [round setSelectedTheme: selectedTheme];
        [realm commitWriteTransaction];
        
        assert(selectedTheme);
        [destVC setRoundID:_roundID];
        [destVC setSelectedThemeID:selectedTheme.ID];
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
