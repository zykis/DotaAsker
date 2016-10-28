//
//  LoadingView.m
//  DotaAsker
//
//  Created by Artem on 27/10/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize loadingLabel = _loadingLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[self layer] setCornerRadius:15];
        [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(0, 0, 50, 50)];
        [_activityIndicatorView startAnimating];
        
        _loadingLabel = [[UILabel alloc] initWithFrame: CGRectMake(50, 0, 150, 50)];
        [_loadingLabel setTextColor:[UIColor whiteColor]];
        
        [self addSubview:_activityIndicatorView];
        [self addSubview:_loadingLabel];
    }
    return self;
}

- (void)setMessage:(NSString *)message {
    [_loadingLabel setText:message];
}

@end
