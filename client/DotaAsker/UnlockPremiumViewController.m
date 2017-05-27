//
//  UnlockPremiumViewController.m
//  DotaAsker
//
//  Created by Artem on 24/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

// Local
#import "UnlockPremiumViewController.h"
#import "ServiceLayer.h"
#import "ModalLoadingView.h"
#import "IAPHelper.h"
#import "SettingsButton.h"

// Libraries
#import <ReactiveObjC/ReactiveObjC/ReactiveObjC.h>

@interface UnlockPremiumViewController ()

@end

@implementation UnlockPremiumViewController

@synthesize verticalStackView = _verticalStackView;
@synthesize loadingView = _loadingView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBackgroundImage];
    
    self.unlockButton.enabled = NO;
    if (!_loadingView)
        _loadingView = [[ModalLoadingView alloc] initWithMessage: NSLocalizedString(@"Checking premium", 0)];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_loadingView];
    
    [self initObserver];
    
    self.helper = [[IAPHelper alloc] init];
    [self.helper validateProductIdentifiers];
}

- (void)initObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProductReady) name:@"productReady" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFail) name:@"fail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleErrorRestored) name:@"errorRestore" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleErrorPurchased) name:@"errorPurchase" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePurchased) name:@"purchased" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRestored) name:@"restored" object:nil];
}

- (void)handleProductReady {
    self.unlockButton.enabled = YES;
    [_loadingView removeFromSuperview];
}

- (void)handleFail {
    [self unsegueWithErrorMessage:NSLocalizedString(@"failed", 0)];
}

- (void)handleErrorRestored {
    [self unsegueWithErrorMessage:NSLocalizedString(@"error restored", 0)];
}

- (void)handleErrorPurchased {
    [self unsegueWithErrorMessage:NSLocalizedString(@"error purchased", 0)];
}

- (void)handlePurchased {
    [self unsegueWithOkMessage:NSLocalizedString(@"purchased", 0)];
}

- (void)handleRestored {
    [self unsegueWithOkMessage:NSLocalizedString(@"restored", 0)];
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
                    UILabel* l = (UILabel*)label;
                    if ([l intrinsicContentSize].width > maxStringWidth) {
                        maxStringWidth = [l intrinsicContentSize].width;
                    }
                }
            }
        }
    }
    
    // [1.1]
    float spacing = 14;
    float constraintWidth = (screenWidth - iconWidth - maxStringWidth - spacing) / 2.0f;
    
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
    else {
        [leading setConstant:-constraintWidth];
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
    else {
        [trailing setConstant:constraintWidth];
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)unsegueWithErrorMessage:(NSString*)errorMessage {
    [_loadingView removeFromSuperview];
    [self presentAlertControllerWithMessage:errorMessage];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)unsegueWithOkMessage:(NSString*)okMessage {
    [_loadingView removeFromSuperview];
    [self presentOkControllerWithMessage:okMessage];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)unlockPressed {
    _loadingView = [[ModalLoadingView alloc] initWithMessage: NSLocalizedString(@"Buying premium", 0)];
    [self.helper buyPremium];
}

- (IBAction)restorePushed:(id)sender {
    _loadingView = [[ModalLoadingView alloc] initWithMessage: NSLocalizedString(@"Buying premium", 0)];
    [self.helper restorePremium];
}
@end
