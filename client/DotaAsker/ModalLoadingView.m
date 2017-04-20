//
//  ModalLoadingView.m
//  DotaAsker
//
//  Created by Artem on 27/03/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import "ModalLoadingView.h"
#import "LoadingView.h"

@implementation ModalLoadingView

- (id)initWithMessage:(NSString*)message {
    CGRect r = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:r];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
        self.userInteractionEnabled = YES;
        
        self.loadingView = [[LoadingView alloc] init];
        [self.loadingView setMessage:message];

        NSUInteger margins = 8;
        CGSize loadingSize = [[loadingView loadingLabel] intrinsicContentSize];
        loadingSize.width += margins * 3;
        loadingSize.width += 16; // Indicator view
        CGPoint loadingPoint = CGPointMake(r.size.width / 2.0 - loadingSize.width / 2.0, r.size.height / 2.0 - loadingSize.height / 2.0);
        CGRect loadingFrame = CGRectMake(loadingPoint, loadingSize);
        
        [self.loadingView setFrame:loadingFrame];
        
        [self addSubview:self.loadingView];
    }
}

- (void)setMessage: (NSString*)message {
    [self.loadingView setMessage:message];
}

@end
