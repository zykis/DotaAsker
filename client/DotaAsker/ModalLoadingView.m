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
        [self addSubview:self.loadingView];
    }
    return self;
}

- (void)setMessage: (NSString*)message {
    [self.loadingView setMessage:message];
}

@end
