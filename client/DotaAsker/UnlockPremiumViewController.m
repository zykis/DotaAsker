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
        _loadingView = [[ModalLoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50) andMessage: NSLocalizedString(@"Checking premium", 0)];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_loadingView];
    [IAPHelper validateProductIdentifiers:productIDs withDelegate:self andStrongRefToRequest:self.productRequest];
}

- (void)didReceiveMemoryWarning {
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
    /* Comment, while troubles with bank info
    if (!_loadingView)
        _loadingView = [[ModalLoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 200 / 2, self.view.frame.size.height / 2 - 50 / 2, 200, 50) andMessage: NSLocalizedString(@"Buying premium", 0)];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_loadingView];
    [IAPHelper buy:self.premiumProduct];
    */
    
    // Will be commented
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [[Player instance] setPremium:YES];
    [realm commitWriteTransaction];

    RACReplaySubject* subject = [[[ServiceLayer instance] userService] update:[Player instance]];
    [subject subscribeNext:^(id x) {
        NSLog(@"Premium updated");
    } error:^(NSError *error) {
        [_loadingView removeFromSuperview];
        [self presentAlertControllerWithMessage:NSLocalizedString([error localuzedDescription], 0)];
    } completed:^{
        [_loadingView removeFromSuperview];
        [self.navigationController popViewControllerAnimated:YES];
        [self presentOkControllerWithMessage:NSLocalizedString(@"Thank you for buying premium!", 0)];
    }];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    self.premiumProduct = [response.products firstObject];
 
    for (SKProduct* product in response.products) {
        NSLog(@"%@", [product productIdentifier]);
    }
    
    /* Comment, while troubles with bank info
    for (NSString *invalidIdentifier in response.invalidProductIdentifiers) {
        NSLog(@"Invalid Product Identifier: %@", invalidIdentifier);
        [_loadingView removeFromSuperview];
        _loadingView = nil;
        [self.navigationController popViewControllerAnimated:YES];
        [self presentAlertControllerWithMessage:NSLocalizedString(@"Product problem. Please, try again later", 0)];
        return;
    }
    */
 
    self.unlockButton.enabled = YES;
    [_loadingView removeFromSuperview];
    _loadingView = nil;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStateDeferred:
                if ([[[[UIApplication sharedApplication] keyWindow] subviews] containsObject:_loadingView])
                    [_loadingView removeFromSuperview];
                break;
            case SKPaymentTransactionStateFailed:
                if ([[[[UIApplication sharedApplication] keyWindow] subviews] containsObject:_loadingView])
                        [_loadingView removeFromSuperview];
                [self presentAlertControllerWithMessage:NSLocalizedString(@"Error, while trying to buy premium", 0)];
                break;
            case SKPaymentTransactionStatePurchased:
            {
                if ([[[[UIApplication sharedApplication] keyWindow] subviews] containsObject:_loadingView])
                    [_loadingView removeFromSuperview];
                
                RLMRealm* realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                [[Player instance] setPremium:YES];
                [realm commitWriteTransaction];

                RACReplaySubject* subject = [[[ServiceLayer instance] userService] update:[Player instance]];
                [subject subscribeNext:^(id x) {
                    NSLog(@"Premium updated");
                } error:^(NSError *error) {
                    //! TODO: store somehow
                    NSLog(@"%@", [error localizedDescription]);
                    [_loadingView removeFromSuperview];
                } completed:^{
                    NSLog(@"Premium update complited");
                    [_loadingView removeFromSuperview];
                }];
                
                [self.navigationController popViewControllerAnimated:YES];
                [self presentOkControllerWithMessage:NSLocalizedString(@"Thank you for buying premium!", 0)];
                break;
            }
            case SKPaymentTransactionStateRestored:
            {
                if ([[[[UIApplication sharedApplication] keyWindow] subviews] containsObject:_loadingView])
                        [_loadingView removeFromSuperview];
                RLMRealm* realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                [[Player instance] setPremium:YES];
                [realm commitWriteTransaction];
                
                RACReplaySubject* subject = [[[ServiceLayer instance] userService] update:[Player instance]];
                [subject subscribeNext:^(id x) {
                    NSLog(@"Premium updated");
                } error:^(NSError *error) {
                    NSLog(@"%@", [error localizedDescription]);
                    [_loadingView removeFromSuperview];
                } completed:^{
                    NSLog(@"Premium update complited");
                    [_loadingView removeFromSuperview];
                }];
                
                [self.navigationController popViewControllerAnimated:YES];
                [self presentOkControllerWithMessage:NSLocalizedString(@"Your purchase has been restored!", 0)];
                break;
            }
            default:
                if ([[[[UIApplication sharedApplication] keyWindow] subviews] containsObject:_loadingView])
                        [_loadingView removeFromSuperview];
                // For debugging
                NSLog(@"Unexpected transaction state %@", @(transaction.transactionState));
                break;
        }
    }
}

@end
