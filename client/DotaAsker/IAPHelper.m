#import "IAPHelper.h"

@implementation IAPHelper

+ (void)validateProductIdentifiers: (NSArray*)product_ids
                      withDelegate: (id<SKProductsRequestDelegate>)delegate
             andStrongRefToRequest: (SKProductsRequest*)request {
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                    initWithProductIdentifiers:[NSSet setWithArray:product_ids]];
 
    // Keep a strong reference to the request.
    request = productsRequest;
    productsRequest.delegate = delegate;
    [productsRequest start];
}

+ (void)buy: (SKProduct*)product {
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

@end
