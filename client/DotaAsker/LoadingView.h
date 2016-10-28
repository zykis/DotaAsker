//
//  LoadingView.h
//  DotaAsker
//
//  Created by Artem on 27/10/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

@property (strong, nonatomic) UIActivityIndicatorView* activityIndicatorView;
@property (strong, nonatomic) UILabel* loadingLabel;

- (void)setMessage:(NSString*)message;

@end
