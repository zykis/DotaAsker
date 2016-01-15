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

@interface ThemeSelectionViewController ()

@end

@implementation ThemeSelectionViewController

@synthesize imagedButton1 = _imagedButton1;
@synthesize imagedButton2 = _imagedButton2;
@synthesize imagedButton3 = _imagedButton3;
@synthesize round = _round;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage* wallpapers = [[[ServiceLayer instance] userService] wallpapersDefault];
    [self loadBackgroundImage:wallpapers];
    
    Theme *theme1 = [[[[ServiceLayer instance] themeService] obtainAll] objectAtIndex:0];
    Theme *theme2 = [[[[ServiceLayer instance] themeService] obtainAll] objectAtIndex:1];
    Theme *theme3 = [[[[ServiceLayer instance] themeService] obtainAll] objectAtIndex:2];
    
    [_imagedButton1 setImage:[[[ServiceLayer instance] themeService] imageForTheme:theme1] forState:UIControlStateNormal];
    [[_imagedButton1 imageView] setContentMode:UIViewContentModeScaleAspectFill];
    
    [_imagedButton2 setImage:[[[ServiceLayer instance] themeService] imageForTheme:theme2] forState:UIControlStateNormal];
    [[_imagedButton2 imageView] setContentMode:UIViewContentModeScaleAspectFill];
    
    [_imagedButton3 setImage:[[[ServiceLayer instance] themeService] imageForTheme:theme3] forState:UIControlStateNormal];
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
            _round.themeID = [(Theme*)[[[ServiceLayer instance] themeService] obtain:1] ID];
        }
        else if([sender isEqual:_imagedButton2]) {
            _round.themeID = [(Theme*)[[[ServiceLayer instance] themeService] obtain:2] ID];
        }
        else if([sender isEqual:_imagedButton3]) {
            _round.themeID = [(Theme*)[[[ServiceLayer instance] themeService] obtain:3] ID];
        }
        else {
            NSLog(@"Can't identify theme pressed");
            return;
        }
        
        _round = [[[ServiceLayer instance] roundService] update:_round];
        [destVC setRound:_round];
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
