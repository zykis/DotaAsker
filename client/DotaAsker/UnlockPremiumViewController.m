//
//  UnlockPremiumViewController.m
//  DotaAsker
//
//  Created by Artem on 24/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "UnlockPremiumViewController.h"
#import "ServiceLayer.h"
#import "ModalLoadingView.h"
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>

@interface UnlockPremiumViewController ()

@end

@implementation UnlockPremiumViewController

@synthesize verticalStackView = _verticalStackView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    float maxStringWidth = 0;
    float screenWidth = self.view.frame.size.width;
    float iconWidth = 50.0f;
    
    // [1] Get maxStringWidth
    for(UIView* subview in [_verticalStackView subviews]) {
        // get horizonal stacks
        if ([subview isKindOfClass:[UIStackView class]]) {
            // get labels
            for(UIView* label in [subview subviews]) {
                if ([label isKindOfClass:[UILabel class]]) {
                    if ([label intrinsicContentSize].width > maxStringWidth)
                        maxStringWidth = [label intrinsicContentSize].width;
                }
            }
        }
    }
    
    // [1.1]
    float spacing = 14;
    float constraintWidth = (screenWidth - iconWidth - maxStringWidth - spacing) / 2.0f;
    constraintWidth -= 5.0f;
    
    // [2] Updating constraints
    NSLayoutConstraint* leading;
    NSLayoutConstraint* trailing;
    for (NSLayoutConstraint* con in self.view.constraints) {
        if (con.secondItem == _verticalStackView)
            if (con.secondAttribute == NSLayoutAttributeLeading)
                leading = con;
            else if (con.secondAttribute == NSLayoutAttributeTrailing)
                trailing = con;
            else
                continue;
        else
            continue;
    }
    
    if (!leading) {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                                        attribute:NSLayoutAttributeLeading
                                                                        relatedBy:NSLayoutRelationEqual
                                                                            toItem:_verticalStackView
                                                                        attribute:NSLayoutAttributeLeading
                                                                        multiplier:1.0
                                                                        constant:-constraintWidth]];
    }
    if (!trailing) {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_verticalStackView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        multiplier:1.0
                                                                        constant:constraintWidth]];
    }
    [leading setConstant:-constraintWidth];
    [trailing setConstant:constraintWidth];
}

- (IBAction)backButtonPressed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)unlockPressed {
    ModalLoadingView* loadingView = [[ModalLoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50) andMessage:@"Unlocking premium"];
    [[[UIApplication sharedApplication] keyWindow] addSubview:loadingView];
    
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [[Player instance] setPremium:YES];
    [realm commitWriteTransaction];

    RACReplaySubject* subject = [[[ServiceLayer instance] userService] update:[Player instance]];
    [subject subscribeNext:^(id x) {
        NSLog(@"Premium updated");
    } error:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
        [loadingView removeFromSuperview];
    } completed:^{
        NSLog(@"Premium update complited");
        [loadingView removeFromSuperview];
    }];
}
@end
