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

- (id)initWithFrame:(CGRect)frame andMessage:(NSString*)message {
    CGRect r = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:r];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
        self.userInteractionEnabled = YES;
        LoadingView* loadingView = [[LoadingView alloc] initWithFrame:frame];
        [loadingView setMessage:message];
        [self addSubview:loadingView];
    }
    return self;
}

@end
