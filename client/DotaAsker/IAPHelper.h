#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface IAPHelper: NSObject

+ (void)validateProductIdentifiers: (NSArray*)product_ids withDelegate: (id<SKProductsRequestDelegate>)delegate andStrongRefToRequest: (SKProductsRequest*)request;
+ (void)buy: (SKProduct*)product;

@end
