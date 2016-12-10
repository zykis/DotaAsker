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
@synthesize round = _round;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray* themes = [[[ServiceLayer instance] roundService] themesForRound:_round];
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
        NSArray* themes = [[[ServiceLayer instance] roundService] themesForRound:_round];
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
        
        assert(selectedTheme);
        [destVC setRound:_round];
        [destVC setSelectedTheme:selectedTheme];
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
    LoadingView* loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50)];
    [loadingView setMessage:@"Updating round"];
    [[self view] addSubview:loadingView];
    
    NSArray* themes = [[[ServiceLayer instance] roundService] themesForRound:_round];
    [_round setSelectedTheme:[themes objectAtIndex:0]];
    RACReplaySubject* subject = [[[ServiceLayer instance] roundService] update:_round];
    [subject subscribeError:^(NSError *error) {
        [self presentAlertControllerWithTitle:@"Round not updated" andMessage:@"Check out connection and try again, please"];
        [loadingView removeFromSuperview];
    } completed:^{
        [loadingView removeFromSuperview];
        [self performSegueWithIdentifier:@"themeSelected" sender:sender];
    }];
}

- (IBAction)button2Pressed:(id)sender {
    LoadingView* loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50)];
    [loadingView setMessage:@"Updating round"];
    [[self view] addSubview:loadingView];
    
    NSArray* themes = [[[ServiceLayer instance] roundService] themesForRound:_round];
    [_round setSelectedTheme:[themes objectAtIndex:1]];
    RACReplaySubject* subject = [[[ServiceLayer instance] roundService] update:_round];
    [subject subscribeError:^(NSError *error) {
        [self presentAlertControllerWithTitle:@"Round not updated" andMessage:@"Check out connection and try again, please"];
        [loadingView removeFromSuperview];
    } completed:^{
        [loadingView removeFromSuperview];
        [self performSegueWithIdentifier:@"themeSelected" sender:sender];
    }];
}

- (IBAction)button3Pressed:(id)sender {
    LoadingView* loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50)];
    [loadingView setMessage:@"Updating round"];
    [[self view] addSubview:loadingView];
    
    NSArray* themes = [[[ServiceLayer instance] roundService] themesForRound:_round];
    [_round setSelectedTheme:[themes objectAtIndex:2]];
    RACReplaySubject* subject = [[[ServiceLayer instance] roundService] update:_round];
    [subject subscribeError:^(NSError *error) {
        [self presentAlertControllerWithTitle:@"Round not updated" andMessage:@"Check out connection and try again, please"];
        [loadingView removeFromSuperview];
    } completed:^{
        [loadingView removeFromSuperview];
        [self performSegueWithIdentifier:@"themeSelected" sender:sender];
    }];
}
@end
