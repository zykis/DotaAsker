// Local
#import "IAPHelper.h"
#import "Player.h"
#import "ServiceLayer.h"

// Libraries
#import <Realm/Realm.h>
#import <ReactiveObjC/ReactiveObjC.h>

@implementation IAPHelper

- (id)init {
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)validateProductIdentifiers {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"product_ids" withExtension:@"plist"];
    NSArray *productIDs = [NSArray arrayWithContentsOfURL:url];
    
    self.premiumRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIDs]];
    self.premiumRequest.delegate = self;
    [self.premiumRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    for (SKProduct* product in response.products) {
        if ([[product productIdentifier] isEqualToString:@"com.dotaasker.premium"])
            self.premiumProduct = product;
    }
    
    for (NSString *invalidIdentifier in response.invalidProductIdentifiers) {
        NSLog(@"Invalid Product Identifier: %@", invalidIdentifier);
        return;
    }
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:self.premiumProduct, @"premiumProduct", nil];
    [self deliverPurchaseNotification:@"premiumReady" andInfo:dict];
}

- (void)buyPremium {
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:self.premiumProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restorePremium {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        NSLog(@"Dealing with %@: %ld", [transaction.payment productIdentifier], (long)transaction.transactionState);
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStateDeferred:
                break;
            case SKPaymentTransactionStateFailed:
                [self fail];
                break;
            case SKPaymentTransactionStatePurchased:
                [self complete];
                break;
            case SKPaymentTransactionStateRestored:
                [self restore];
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    [self restore];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [self fail];
}

- (void)complete {
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [[Player instance] setPremium:YES];
    [realm commitWriteTransaction];
    
    RACReplaySubject* subject = [[[ServiceLayer instance] userService] update:[Player instance]];
    [subject subscribeError:^(NSError *error) {
        [self deliverPurchaseNotification:@"errorPurchase"];
    } completed:^{
        [self deliverPurchaseNotification:@"purchased"];
    }];
}

- (void)restore {
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [[Player instance] setPremium:YES];
    [realm commitWriteTransaction];
    
    RACReplaySubject* subject = [[[ServiceLayer instance] userService] update:[Player instance]];
    [subject subscribeError:^(NSError *error) {
        [self deliverPurchaseNotification:@"errorRestore"];
    } completed:^{
        [self deliverPurchaseNotification:@"restored"];
    }];
}

- (void)fail {
    [self deliverPurchaseNotification:@"fail"];
}

- (void)deliverPurchaseNotification:(NSString*)notification andInfo:(NSDictionary*)info {
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:self userInfo:info];
}

- (void)deliverPurchaseNotification:(NSString*)notification {
    [self deliverPurchaseNotification:notification andInfo:nil];
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
