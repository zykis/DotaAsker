//
//  UnlockPremiumViewController.h
//  DotaAsker
//
//  Created by Artem on 24/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"

@interface UnlockPremiumViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver>
- (IBAction)unlockPressed;
@property (weak, nonatomic) IBOutlet UIStackView* verticalStackView;
@property (strong, nonatomic) ModalLoadingView* loadingView;
@property (strong, nonatomic) SKProduct* premiumProduct;
@property (strong, nonatomic) SKProductsRequest* productRequest;

@end
