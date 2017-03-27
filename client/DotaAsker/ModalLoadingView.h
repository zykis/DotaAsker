//
//  ModalLoadingView.h
//  DotaAsker
//
//  Created by Artem on 27/03/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoadingView;

@interface ModalLoadingView : UIView

@property (strong, nonatomic) LoadingView* loadingView;
- (id)initWithFrame:(CGRect)frame andMessage:(NSString*)message;
- (void)setMessage:(NSString*)message;

@end
