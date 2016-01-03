//
//  TestViewController.m
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "TestViewController.h"
#import "ServiceLayer.h"

@interface TestViewController ()
@end

@implementation TestViewController

@synthesize serviceLayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    serviceLayer = [[ServiceLayer alloc] init];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onButton {
    UserAnswer *ua = [[serviceLayer userAnswerService] obtain:1];
    if (ua) {
        [[self label] setText:[NSString stringWithFormat:@"%ld", [ua ID]]];
    }
    else {
        [[self label] setText:@"UserAnswer wasn't obtain"];
    }
}
@end
