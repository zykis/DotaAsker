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
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    self.unlockButton.enabled = NO;
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"product_ids" withExtension:@"plist"];
    NSArray *productIDs = [NSArray arrayWithContentsOfURL:url];

    if (!_loadingView)
        _loadingView = [[ModalLoadingView alloc] initWithMessage: NSLocalizedString(@"Checking premium", 0)];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_loadingView];
    [IAPHelper validateProductIdentifiers:productIDs withDelegate:self andStrongRefToRequest:self.productRequest];
    
}

- (void)didReceiveMemoryWarning {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [super didReceiveMemoryWarning];
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

- (IBAction)unlockPressed {
    if (!_loadingView)
        _loadingView = [[ModalLoadingView alloc] initWithMessage: NSLocalizedString(@"Buying premium", 0)];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_loadingView];
    //! TODO: check somehow, if observer is setted
    //! TODO: check if self.premiumProduct is valid
    if (self.premiumProduct == nil)
    {
        [self presentAlertControllerWithMessage:NSLocalizedString(@"premiumProduct is nil", 0)];
        return;
    }
    if (![[self.premiumProduct productIdentifier] isEqualToString:@"com.dotaasker.premium"])
    {
        [self presentAlertControllerWithMessage:NSLocalizedString(@"premiumProduct identifier is incorrect", 0)];
        return;
    }
    [IAPHelper buy:self.premiumProduct];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    for (SKProduct* product in response.products) {
        if ([[product productIdentifier] isEqualToString:@"com.dotaasker.premium"])
            self.premiumProduct = product;
    }
    
    for (NSString *invalidIdentifier in response.invalidProductIdentifiers) {
        NSLog(@"Invalid Product Identifier: %@", invalidIdentifier);
        [_loadingView removeFromSuperview];
        _loadingView = nil;
        [self.navigationController popViewControllerAnimated:YES];
        [self presentAlertControllerWithMessage:NSLocalizedString(@"Invalid Product Identifier", 0)];
        return;
    }    

    self.unlockButton.enabled = YES;
    [_loadingView removeFromSuperview];
    _loadingView = nil;
}

- (void)restore {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    [_loadingView removeFromSuperview];
    
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [[Player instance] setPremium:YES];
    [realm commitWriteTransaction];
    
    RACReplaySubject* subject = [[[ServiceLayer instance] userService] update:[Player instance]];
    [subject subscribeNext:^(id x) {
        NSLog(@"Premium updated");
    } error:^(NSError *error) {
        [self presentAlertControllerWithMessage:NSLocalizedString(@"Couldn't restore. Try again, please", 0)];
    } completed:^{
        [_loadingView removeFromSuperview];
        [self presentOkControllerWithMessage:NSLocalizedString(@"Your purchase has been restored!", 0)];
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        NSLog(@"Dealing with %@", [transaction.payment productIdentifier]);
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStateDeferred:
                [_loadingView removeFromSuperview];
                break;
            case SKPaymentTransactionStateFailed:
                [_loadingView removeFromSuperview];
                [self presentAlertControllerWithMessage:NSLocalizedString([[transaction error] localizedDescription], 0)];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStatePurchased:
            {
                [_loadingView removeFromSuperview];
                
                RLMRealm* realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                [[Player instance] setPremium:YES];
                [realm commitWriteTransaction];

                RACReplaySubject* subject = [[[ServiceLayer instance] userService] update:[Player instance]];
                [subject subscribeNext:^(id x) {
                    NSLog(@"Premium updated");
                } error:^(NSError *error) {
                    [self presentAlertControllerWithMessage:NSLocalizedString([[transaction error] localizedDescription], 0)];
                } completed:^{
                    [_loadingView removeFromSuperview];
                    [self presentOkControllerWithMessage:NSLocalizedString(@"Thank you for buying premium!", 0)];
                }];
                
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case SKPaymentTransactionStateRestored:
            {
                [_loadingView removeFromSuperview];
                
                RLMRealm* realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                [[Player instance] setPremium:YES];
                [realm commitWriteTransaction];
                
                RACReplaySubject* subject = [[[ServiceLayer instance] userService] update:[Player instance]];
                [subject subscribeNext:^(id x) {
                    NSLog(@"Premium updated");
                } error:^(NSError *error) {
                    [self presentAlertControllerWithMessage:NSLocalizedString([[transaction error] localizedDescription], 0)];
                } completed:^{
                    [_loadingView removeFromSuperview];
                    [self presentOkControllerWithMessage:NSLocalizedString(@"Your purchase has been restored!", 0)];
                }];
                
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            default:
                [_loadingView removeFromSuperview];
                NSLog(@"Unexpected transaction state %@", @(transaction.transactionState));
                break;
        }
    }
}

- (IBAction)restorePushed:(id)sender {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
@end
