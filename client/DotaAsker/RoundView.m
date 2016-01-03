//
//  RoundView.m
//  DotaAsker
//
//  Created by Artem on 30/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "AnswerItemView.h"
#import "RoundView.h"

#define QUESTIONS_IN_ROUND 3
#define MARGIN_ANSWERS 10.0f

@implementation RoundView

@synthesize roundNumberLabel = _roundNumberLabel;
@synthesize themeNameLabel = _themeNameLabel;
@synthesize leftAnswerViews = _leftAnswerViews;
@synthesize rightAnswerViews = _rightAnswerViews;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self base_init];
        
        [_rightAnswerViews setObject:[self viewWithTag:101] atIndexedSubscript:0];
        [_rightAnswerViews setObject:[self viewWithTag:102] atIndexedSubscript:1];
        [_rightAnswerViews setObject:[self viewWithTag:103] atIndexedSubscript:2];
        
        [_leftAnswerViews setObject:[self viewWithTag:104] atIndexedSubscript:0];
        [_leftAnswerViews setObject:[self viewWithTag:105] atIndexedSubscript:1];
        [_leftAnswerViews setObject:[self viewWithTag:106] atIndexedSubscript:2];
        
        for (AnswerItemView* view in _rightAnswerViews) {
            [view setDelegate:self];
        }
        for (AnswerItemView* view in _leftAnswerViews) {
            [view setDelegate:self];
        }
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

- (void)base_init {
    _roundNumberLabel = [[UILabel alloc] init];
    _themeNameLabel = [[UILabel alloc] init];
    _leftAnswerViews = [[NSMutableArray alloc] init];
    _rightAnswerViews = [[NSMutableArray alloc] init];
    UIImage *resizableImage = [[UIImage imageNamed:@"cell2.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 38, 44, 57)];
    self.layer.contents = (id)resizableImage.CGImage;
}



- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)setupConstraints {
    //removing autoresing masks from views
    //let our constraints do all the job
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_roundNumberLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_themeNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (_leftAnswerViews)
        for (int i = 0; i < QUESTIONS_IN_ROUND; i++) {
            [[_leftAnswerViews objectAtIndex:i] setTranslatesAutoresizingMaskIntoConstraints:NO];
        }
    if(_rightAnswerViews)
        for (int i = 0; i < QUESTIONS_IN_ROUND; i++) {
            [[_rightAnswerViews objectAtIndex:i] setTranslatesAutoresizingMaskIntoConstraints:NO];
        }
    
    //equal width and heights for all answerViews
    for (int i = 0; i < QUESTIONS_IN_ROUND; i++) {
        if (i != 0) {
            [self addConstraint:[NSLayoutConstraint
                            constraintWithItem:[_leftAnswerViews objectAtIndex:0]
                            attribute:NSLayoutAttributeWidth
                            relatedBy:0
                            toItem:[_leftAnswerViews objectAtIndex:i]
                            attribute:NSLayoutAttributeWidth
                             multiplier:1.0 constant:0]];
            [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:[_leftAnswerViews objectAtIndex:0]
                             attribute:NSLayoutAttributeHeight
                             relatedBy:0
                             toItem:[_leftAnswerViews objectAtIndex:i]
                             attribute:NSLayoutAttributeHeight
                             multiplier:1.0 constant:0]];
        }
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:[_leftAnswerViews objectAtIndex:0]
                             attribute:NSLayoutAttributeWidth
                             relatedBy:0
                             toItem:[_rightAnswerViews objectAtIndex:i]
                             attribute:NSLayoutAttributeWidth
                             multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:[_leftAnswerViews objectAtIndex:0]
                             attribute:NSLayoutAttributeHeight
                             relatedBy:0
                             toItem:[_rightAnswerViews objectAtIndex:i]
                             attribute:NSLayoutAttributeHeight
                             multiplier:1.0 constant:0]];
    }
    
    //[UIView <--> _roundNumberLabel] top space contraint
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_roundNumberLabel
                         attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeTop
                         multiplier:1 constant:5.0f]];
    //[_roundNumberLabel <--> _themeLabelName] vertical space
//    [self addConstraint:[NSLayoutConstraint
//                         constraintWithItem:_roundNumberLabel
//                         attribute:NSLayoutAttributeBottom
//                         relatedBy:NSLayoutRelationEqual
//                         toItem:_themeNameLabel
//                         attribute:NSLayoutAttributeTop
//                         multiplier:1 constant:-15.0f]];
    //[_themeNameLabel <--> UIView] bottom space
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_themeNameLabel
                         attribute:NSLayoutAttributeBottom
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeBottom
                         multiplier:1 constant:-5.0f]];
    
    //[_roundNumberLabel.width == _themeNameLabel.width]
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_roundNumberLabel
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:_themeNameLabel
                         attribute:NSLayoutAttributeWidth
                         multiplier:1 constant:0.0f]];
    //[_roundNumberLabel center horizontally]
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_roundNumberLabel
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1 constant:0.0f]];
    //[_themeNameLabel center horizontally]
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_themeNameLabel
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1 constant:0.0f]];
    
//    //[_roundNumberLabel.left == _themeNameLabel.left]
//    [self addConstraint:[NSLayoutConstraint
//                         constraintWithItem:_themeNameLabel
//                         attribute:NSLayoutAttributeLeft
//                         relatedBy:NSLayoutRelationEqual
//                         toItem:_roundNumberLabel
//                         attribute:NSLayoutAttributeLeft
//                         multiplier:1 constant:0.0f]];
//    
//    //[_roundNumberLabel.right == _themeNameLabel.right]
//    [self addConstraint:[NSLayoutConstraint
//                         constraintWithItem:_themeNameLabel
//                         attribute:NSLayoutAttributeRight
//                         relatedBy:NSLayoutRelationEqual
//                         toItem:_roundNumberLabel
//                         attribute:NSLayoutAttributeRight
//                         multiplier:1 constant:0.0f]];
    
    //[_leftAnswerViews <--> UIView] top and bot constraints
    for (int i = 0; i < QUESTIONS_IN_ROUND; i++) {
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:[_leftAnswerViews objectAtIndex:i]
                             attribute:NSLayoutAttributeTop
                             relatedBy:NSLayoutRelationEqual
                             toItem:self
                             attribute:NSLayoutAttributeTop
                             multiplier:1 constant:MARGIN_ANSWERS]];
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:[_leftAnswerViews objectAtIndex:i]
                             attribute:NSLayoutAttributeBottom
                             relatedBy:NSLayoutRelationEqual
                             toItem:self
                             attribute:NSLayoutAttributeBottom
                             multiplier:1 constant:-MARGIN_ANSWERS]];
    }
    
    //[_leftAnswerViews <--> UIView] left constraint
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:[_leftAnswerViews objectAtIndex:0]
                         attribute:NSLayoutAttributeLeft
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeLeft
                         multiplier:1 constant:MARGIN_ANSWERS]];
    //[_leftAnswerViews <--> _themeLabelName] horizontal space
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:[_leftAnswerViews objectAtIndex:QUESTIONS_IN_ROUND - 1]
                         attribute:NSLayoutAttributeRight
                         relatedBy:NSLayoutRelationEqual
                         toItem: _themeNameLabel
                         attribute:NSLayoutAttributeLeft
                         multiplier:1 constant:MARGIN_ANSWERS]];
    //[_leftAnswerViews <--> _leftAnswersViews] horizontal space = 0
    for (int i = 0; i < QUESTIONS_IN_ROUND - 1; i++) {
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:[_leftAnswerViews objectAtIndex:i]
                             attribute:NSLayoutAttributeRight
                             relatedBy:NSLayoutRelationEqual
                             toItem:[_leftAnswerViews objectAtIndex:i+1]
                             attribute:NSLayoutAttributeLeft
                             multiplier:1 constant:0.0f]];
    }
    
    //[_rightAnswerViews <--> UIView] top and bot constraints
    for (int i = 0; i < QUESTIONS_IN_ROUND; i++) {
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:[_rightAnswerViews objectAtIndex:i]
                             attribute:NSLayoutAttributeTop
                             relatedBy:NSLayoutRelationEqual
                             toItem:self
                             attribute:NSLayoutAttributeTop
                             multiplier:1 constant:MARGIN_ANSWERS]];
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:[_rightAnswerViews objectAtIndex:i]
                             attribute:NSLayoutAttributeBottom
                             relatedBy:NSLayoutRelationEqual
                             toItem:self
                             attribute:NSLayoutAttributeBottom
                             multiplier:1 constant:-MARGIN_ANSWERS]];
    }
    //[_rightAnswerViews <--> UIView] right constraints
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:[_rightAnswerViews objectAtIndex:QUESTIONS_IN_ROUND - 1]
                         attribute:NSLayoutAttributeRight
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeRight
                         multiplier:1 constant:-MARGIN_ANSWERS]];
    //[_themeLabelName <--> _rightAnswerViews] horizontal space
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_themeNameLabel
                         attribute:NSLayoutAttributeLeft
                         relatedBy:NSLayoutRelationEqual
                         toItem: [_rightAnswerViews objectAtIndex:0]
                         attribute:NSLayoutAttributeRight
                         multiplier:1 constant:MARGIN_ANSWERS]];
    //[_rightAnswerViews <--> _rightAnswerViews] horizontal space = 0
    for (int i = 0; i < QUESTIONS_IN_ROUND - 1; i++) {
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:[_rightAnswerViews objectAtIndex:i]
                             attribute:NSLayoutAttributeRight
                             relatedBy:NSLayoutRelationEqual
                             toItem:[_rightAnswerViews objectAtIndex:i+1]
                             attribute:NSLayoutAttributeLeft
                             multiplier:1 constant:0.0f]];
    }
    //[_rightAnswerViews <--> UIVIew] right constraint
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:[_rightAnswerViews objectAtIndex:QUESTIONS_IN_ROUND - 1]
                         attribute:NSLayoutAttributeRight
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeRight
                         multiplier:1 constant:-MARGIN_ANSWERS]];
}

- (void)answerItemViewWasTapped:(AnswerItemView *)answerItemView {
    NSInteger index = [_leftAnswerViews indexOfObjectIdenticalTo:answerItemView];
    if (index == NSNotFound) {
        index = [_rightAnswerViews indexOfObjectIdenticalTo:answerItemView];
        if (index == NSNotFound) {
            NSLog(@"Tapped answer not found");
            return;
        }
    }
    [self.delegate roundViewAnswerWasTapped:self atIndex:index];
}

@end
