//
//  Database.m
//  DotaAsker
//
//  Created by Artem on 12/10/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "Database.h"
#import "Question.h"
#import "Theme.h"
#import "Answer.h"
#import "Client.h"

#define kDataFile @"questions.data"
#define kDataKey @"Data"


@implementation Database

@synthesize localQuestions = _localQuestions;
@synthesize kPathToQuestionsFolder = _kPathToQuestionsFolder;

+ (id)instance {
    static Database *database = nil;
    @synchronized(self) {
        if(database == nil)
            database = [[self alloc] init];
    }
    return database;
}

- (id)init {
    self = [super init];
    if (self) {
        _localQuestions = [[NSMutableArray alloc] init];
        _kPathToQuestionsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onNotificationSynchronizeQuestions:)
                                                     name:@"synchronize_questions" object:nil];
    }
    return self;
}

- (void)loadQuestions {
    if ([_localQuestions count] != 0) {
        [self removeLocalQuestions];
    }
    NSString *dataPath = [_kPathToQuestionsFolder stringByAppendingPathComponent:kDataFile];
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:dataPath];
    if (codedData == nil) return;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    _localQuestions = [unarchiver decodeObjectForKey:kDataKey];
    [unarchiver finishDecoding];
}

- (void)onNotificationSynchronizeQuestions:(NSNotification *)aNotification {
    if ([_localQuestions count] == 0) {
        [self loadQuestions];
    }
    NSDictionary *dictQuestions = [aNotification userInfo];
    NSArray *addQuestions = [dictQuestions valueForKey:@"add_questions"];
    NSArray *removeQuestionsIDs = [dictQuestions valueForKey:@"remove_questions_IDs"];
    
    //remove questions with IDs in 'removeQuestionsIDs'
    if ([removeQuestionsIDs count] != 0) {
        for (int i = 0; i < [_localQuestions count]; i++) {
            if ([removeQuestionsIDs containsObject: [NSNumber numberWithLong: [[_localQuestions objectAtIndex:i] ID]]]) {
                [_localQuestions removeObjectAtIndex:i];
                [self saveLocalQuestions];
            }
        }
    }
    
    //add new questions
    for (NSDictionary *qDict in addQuestions) {
        Question* q = [Question fromJSON:qDict];
        [_localQuestions addObject:q];
    }
    
    //save localQuestions to disk
    [self saveLocalQuestions];
}

- (void)saveLocalQuestions {
    NSString *dataPath = [_kPathToQuestionsFolder stringByAppendingPathComponent:kDataFile];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_localQuestions forKey:kDataKey];
    [archiver finishEncoding];
    NSError *anError;
    if (![data writeToFile:dataPath options:NSDataWritingFileProtectionNone error:&anError]) {
        NSLog(@"Can't write questions to file: %@", dataPath);
        NSLog(@"%@", anError);
    }
}

- (Question*)questionByID:(NSInteger)questionID {
    Question *q;
    int i = 0;
    for (Question *qu in _localQuestions) {
        if (qu.ID == questionID) {
            q = qu;
            break;
        }
        i++;
    }
    
    if (!q) {
        NSLog(@"Can't find quesiton in local DB with id = %ld", (long)questionID);
        //upload question from Server
        [[Client instance] sendMessageSynchronizeQuestions];
        return nil;
    }
    return q;
}

- (NSMutableArray*)generateQuestionsOnTheme:(Theme *)aTheme {
    //getting questions on theme
    NSMutableArray *themedQuestion = [[NSMutableArray alloc] init];
    NSMutableArray *resultQuestions = [[NSMutableArray alloc] init];
    for (Question *q in [[Database instance] localQuestions]) {
        if ([q.theme isEqual:aTheme]) {
            [themedQuestion addObject:q];
        }
    }
    
    //randomizing 3 questions from array
    for (int i = 0; i < 3; i++) {
        long number = arc4random_uniform((unsigned int)[themedQuestion count] - 1);
        if (number < 0) {
            NSLog(@"Can't generate a question: no more questions in DB on theme: %@", [aTheme name]);
            return nil;
        }
        Question *q = [themedQuestion objectAtIndex:number];
        [resultQuestions addObject:q];
        [themedQuestion removeObject:q];
    }
    return resultQuestions;
}

- (void)removeLocalQuestion:(Question *)question {
    if ([_localQuestions containsObject:question]) {
        [_localQuestions removeObject:question];
    }
}

- (void)removeLocalQuestions {
    [_localQuestions removeAllObjects];
    [self saveLocalQuestions];
}

@end
