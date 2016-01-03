//
//  ThemeSelectionViewController.m
//  DotaAsker
//
//  Created by Artem on 14/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "ThemeSelectionViewController.h"
#import "ThemeSelectedViewController.h"
#import "Match.h"

@interface ThemeSelectionViewController ()

@end

@implementation ThemeSelectionViewController

@synthesize imagedButton1 = _imagedButton1;
@synthesize imagedButton2 = _imagedButton2;
@synthesize imagedButton3 = _imagedButton3;
@synthesize match = _match;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    
    Theme *theme1 = [[Theme getAllThemes] objectAtIndex:0];
    Theme *theme2 = [[Theme getAllThemes] objectAtIndex:1];
    Theme *theme3 = [[Theme getAllThemes] objectAtIndex:2];
    
    [_imagedButton1 setImage:[theme1 image] forState:UIControlStateNormal];
    [[_imagedButton1 imageView] setContentMode:UIViewContentModeScaleAspectFill];
    
    [_imagedButton2 setImage:[theme2 image] forState:UIControlStateNormal];
    [[_imagedButton2 imageView] setContentMode:UIViewContentModeScaleAspectFill];
    
    [_imagedButton3 setImage:[theme3 image] forState:UIControlStateNormal];
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
        if ([sender isEqual:_imagedButton1]) {
            [[_match currentRound] setTheme:[[Theme getAllThemes] objectAtIndex:0]];
        }
        else if([sender isEqual:_imagedButton2]) {
            [[_match currentRound] setTheme:[[Theme getAllThemes] objectAtIndex:1]];
        }
        else if([sender isEqual:_imagedButton3]) {
            [[_match currentRound] setTheme:[[Theme getAllThemes] objectAtIndex:2]];
        }
        else {
            NSLog(@"Can't identify theme pressed");
            return;
        }
        
        [destVC setMatch:[self match]];
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
