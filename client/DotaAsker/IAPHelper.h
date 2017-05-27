#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface IAPHelper: NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property SKProduct* premiumProduct;
@property SKProductsRequest* premiumRequest;
- (void)validateProductIdentifiers;
- (void)buyPremium;
- (void)restorePremium;

@end
