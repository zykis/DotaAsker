//
//  SubmitQuiestionViewController.m
//  DotaAsker
//
//  Created by Artem on 20/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "SubmitQuiestionViewController.h"
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>
#import "ServiceLayer.h"
#import "ModalLoadingView.h"

@interface SubmitQuiestionViewController ()

@end

@implementation SubmitQuiestionViewController

@synthesize textField = _textField;
@synthesize answer1 = _answer1;
@synthesize answer2 = _answer2;
@synthesize answer3 = _answer3;
@synthesize answer4 = _answer4;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.sheetView.layer.cornerRadius = 8;
    self.sheetView.layer.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.4].CGColor;
}

- (IBAction)backButtonPressed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)submit {
    // If question and at least 2 answers is not empty, submit question
    if ([[self.textField text] isEqualToString:@""]) {
        [self presentAlertControllerWithMessage:@"No question text"];
        return;
    }
    Question* newQ = [[Question alloc] init];
    // text
    [newQ setText:[_textField text]];
    // answers
    if (![[_answer1 text] isEqualToString:@""]) {
        Answer* a1 = [[Answer alloc] init];
        [a1 setText:[_answer1 text]];
        [a1 setIsCorrect:YES];
        [[newQ answers] addObject:a1];
    }
    if (![[_answer2 text] isEqualToString:@""]) {
        Answer* a = [[Answer alloc] init];
        [a setText:[_answer2 text]];
        [a setIsCorrect:NO];
        [[newQ answers] addObject:a];
    }
    if (![[_answer3 text] isEqualToString:@""]) {
        Answer* a = [[Answer alloc] init];
        [a setText:[_answer3 text]];
        [a setIsCorrect:NO];
        [[newQ answers] addObject:a];
    }
    if (![[_answer4 text] isEqualToString:@""]) {
        Answer* a = [[Answer alloc] init];
        [a setText:[_answer4 text]];
        [a setIsCorrect:NO];
        [[newQ answers] addObject:a];
    }
    
    ModalLoadingView* loadingView = [[ModalLoadingView alloc] initWithMessage:NSLocalizedString(@"Submiting question", 0)];
    [[[UIApplication sharedApplication] keyWindow] addSubview:loadingView];
        
    RACReplaySubject* subject = [[[ServiceLayer instance] questionService] submitQuestion:newQ];
    [subject subscribeNext:^(id x) {
    } error:^(NSError *error) {
        [self presentAlertControllerWithMessage:[error localizedDescription]];
        [loadingView removeFromSuperview];
    } completed:^{
        [self presentOkControllerWithMessage:@"Thank you!"];
        [loadingView removeFromSuperview];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
@end
