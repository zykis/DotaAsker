//
//  Client.h
//  DotaAsker
//
//  Created by Artem on 18/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#define MAX_BUFFER_SIZE 10240000
#define BUFFER_SIZE 1024
//#define SERVER_IP @"10.211.55.5" //UBUNTU SERVER
//#define SERVER_IP @"172.20.10.2" //REAL DEVICE
#define SERVER_IP @"127.0.0.1" //IOS IMULATOR
#define SERVER_PORT 1536
#define BUFFER_WRITE_LENGTH 1024

@class Round;
@class Match;
@class UserAnswer;

@interface Client : NSObject<NSStreamDelegate>

+ (id)instance;
- (id)init;

@property (strong, nonatomic) NSString *serverIP;
@property (assign, nonatomic) unsigned int serverPort;
@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;
@property (strong, nonatomic) NSString *currentCommand;
@property (strong, nonatomic) UIAlertController *alertController;
@property (strong, nonatomic) NSMutableData *data;

@property (strong, nonatomic) NSMutableArray *dataWriteQueue;
@property (assign, nonatomic) BOOL bCanSendData;
@property (assign, nonatomic) NSInteger currentDataOffset;

- (void)connect;
- (BOOL)connected;

- (void)sendMessageSignInWithUsername:(NSString *) aUsername
                          andPassword:(NSString *) aPassword;
- (void)sendMessageSignUpWithUsername:(NSString*) aUsername
                          andPassword:(NSString*) aPassword
                             andEmail: (NSString*)anEmail;
- (void)sendMessageGetUserInfo:(NSString*) aUsername;
- (void)sendMessageGetPlayerInfo:(NSString*) aUsername;
- (void)sendMessageUpdateRound:(Round*) round;
- (void)sendMessageUpdateMatch:(Match*) match;
- (void)sendMessageUpdateUser:(User*) user;
- (void)sendMessagePostUserAnswer:(UserAnswer*) userAnswer;
- (void)sendMessageFindMatch;
- (void)sendMessageSynchronizeQuestions;

@end
