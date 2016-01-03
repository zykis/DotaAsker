//
//  AnswerItemView.m
//  DotaAsker
//
//  Created by Artem on 02/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "AnswerItemView.h"

@implementation AnswerItemView

@synthesize answerState = _answerState;
@synthesize tapRecognizer = _tapRecognizer;

- (void)base_init {
    _answerState = 0;
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:_tapRecognizer];
    [self setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.0f]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self base_init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self base_init];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    UIColor *color;
    if (_answerState == 0) {
        //answer incorrect
        color = [[UIColor redColor] colorWithAlphaComponent:0.55f];
    }
    else if (_answerState == 1) {
        //answer correct
        color = [[UIColor greenColor] colorWithAlphaComponent:0.55f];
    }
    else {
        //answer is hidden
        color = [[UIColor grayColor] colorWithAlphaComponent:0.55f];
    }
    [color setFill];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:4.0f];
    [path fill];
}

- (void)setAnswerState:(NSInteger)answerState {
    if (answerState != _answerState) {
        if (answerState != 2) {
            if(![[self gestureRecognizers] containsObject:_tapRecognizer])
                [self addGestureRecognizer:_tapRecognizer];
        }
        else {
            if([[self gestureRecognizers] containsObject:_tapRecognizer])
                [self removeGestureRecognizer:_tapRecognizer];
        }
        _answerState = answerState;
        [self setNeedsDisplay];
    }
}

- (void)handleTapGesture:(UIGestureRecognizer*) tapGesture {
    [self.delegate answerItemViewWasTapped:self];
}

@end
