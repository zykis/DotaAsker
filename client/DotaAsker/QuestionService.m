//
//  QuestionService.m
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "QuestionService.h"
#import "ThemeService.h"
#import "QuestionParser.h"
#import "QuestionTransport.h"

@implementation QuestionService

@synthesize transport;
@synthesize parser;
@synthesize cache;

- (id)init {
    self = [super init];
    if(self) {
        parser = [[QuestionParser alloc] init];
        cache = [[AbstractCache alloc] init];
        transport = [[QuestionTransport alloc] init];
    }
    return self;
}

+ (QuestionService*)instance {
    static QuestionService *questionService = nil;
    @synchronized(self) {
        if(questionService == nil)
            questionService = [[self alloc] init];
    }
    return questionService;
}

- (NSArray*)allQuestionsOnTheme:(Theme *)theme {
    NSMutableArray* questions = [[self obtainAll] mutableCopy];
    for (int i = 0; i < [questions count]; i++) {
        Question* q = [questions objectAtIndex:i];
        Theme* t = [[ThemeService instance] obtain:[q themeID]];
        if (t != theme) {
            [questions removeObject:q];
        }
    }
    return questions;
}

- (NSArray*)generateQuestionsOnTheme:(Theme *)theme {
    NSMutableArray* themedQuestions = [[self allQuestionsOnTheme:theme] mutableCopy];
    NSMutableArray* resultQuestions = [[NSMutableArray alloc] init];
    //randomizing 3 questions from array
    for (int i = 0; i < 3; i++) {
        long number = arc4random_uniform((unsigned int)[themedQuestions count] - 1);
        if (number < 0) {
            NSLog(@"Can't produce a question: no more questions in DB on theme: %@", [theme name]);
            return nil;
        }
        Question *q = [themedQuestions objectAtIndex:number];
        [resultQuestions addObject:q];
        [themedQuestions removeObject:q];
    }
    return resultQuestions;
}

- (UIImage*)imageOfQuestion:(Question *)question {
    UIImage* image = [UIImage imageNamed:[question imageName]];
    return image;
}

- (Question*)questionAtIndex:(NSInteger)index ofRound:(Round *)round {
    if (index >= [[round questionsIDs] count]) {
        return nil;
    }
    else {
        NSInteger questionID = [[[round questionsIDs] objectAtIndex:index] integerValue];
        Question* q = [self obtain:questionID];
        return q;
    }
}

@end
