//
//  Client.m
//  DotaAsker
//
//  Created by Artem on 18/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import "Client.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "AppDelegate.h"
#import "UIViewController+Utils.h"
#import "Player.h"
#import "Question.h"
#import "Database.h"
#import "Round.h"
#import "UserAnswer.h"
#import "Match.h"

@implementation Client

@synthesize serverIP = _serverIP;
@synthesize serverPort = _serverPort;
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize alertController = _alertController;
@synthesize currentCommand = _currentCommand;

@synthesize data = _data;
@synthesize dataWriteQueue = _dataWriteQueue;
@synthesize bCanSendData = _bCanSendData;
@synthesize currentDataOffset;

+ (id)instance {
    static Client *client = nil;
    @synchronized(self) {
        if(client == nil)
            client = [[self alloc] init];
    }
    return client;
}

- (id)init {
    self = [super init];
    if(self) {
        _serverIP = SERVER_IP;
        _serverPort = SERVER_PORT;
        _data = [[NSMutableData alloc] init];
        _dataWriteQueue = [[NSMutableArray alloc] init];
        _bCanSendData = NO;
        currentDataOffset = 0;
    }
    return self;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if (aStream == _outputStream) {
        switch (eventCode) {
            case NSStreamEventNone:
                break;
                
            case NSStreamEventHasBytesAvailable:
                break;
                
            case NSStreamEventEndEncountered:
                break;
                
            case NSStreamEventErrorOccurred:
                break;
                
            case NSStreamEventOpenCompleted:
                break;
                
            case NSStreamEventHasSpaceAvailable:
                _bCanSendData = YES;
                [self sendData];
                break;
                
            default:
                break;
        }
    }
    else if (aStream == _inputStream) {
        switch (eventCode) {
            case NSStreamEventNone:
                break;
                
            case NSStreamEventHasBytesAvailable:
                [self onInputStreamEventHasBytesAvailable:aStream];
                break;
                
            case NSStreamEventEndEncountered:
                break;
                
            case NSStreamEventErrorOccurred:
                break;
                
            case NSStreamEventOpenCompleted:
                break;
                
            case NSStreamEventHasSpaceAvailable:
                break;
                
            default:
                break;
        }
    }
}

- (void)connect {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)_serverIP,
                                       _serverPort, &readStream, &writeStream);
    _inputStream = (__bridge NSInputStream *)readStream;
    _outputStream = (__bridge NSOutputStream *)writeStream;
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
        [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                 forMode:NSDefaultRunLoopMode];
        [_inputStream open];
        [_outputStream open];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)pushMessageToQueue:(NSDictionary*) JSONDict {
    NSError *error;
    NSData *dataToTransmit = [NSJSONSerialization
                              dataWithJSONObject:JSONDict
                              options:kNilOptions error:&error];
    if(error) {
        NSLog(@"Queue. Error occured, while parsing a message: %@",error);
        return;
    }
    if ([[JSONDict objectForKey:@"command"] isEqualToString:@""]) {
        NSLog(@"Queue. Parsing problem: \"command\" key is empty");
        return;
    }
    
    //if JSON is serializable, add it to Queue
    [_dataWriteQueue addObject:dataToTransmit];
    if (_bCanSendData) {
        [self sendData];
    }
}

- (void)sendData {
    _bCanSendData = NO;
    if ([_dataWriteQueue count] == 0) {
        _bCanSendData = YES;
        return;
    }
    else {
        NSData* data = [_dataWriteQueue firstObject];
        if (data == nil) {
            _bCanSendData = YES;
            return;
        }
        
        //sending data
        uint8_t *readBytes = (uint8_t *)[data bytes];
        readBytes += currentDataOffset;
        NSUInteger dataLength = [data length];
        NSUInteger lengthOfDataToWrite = (dataLength - currentDataOffset >= BUFFER_WRITE_LENGTH) ?
                                        BUFFER_WRITE_LENGTH : (dataLength - currentDataOffset);
        NSInteger bytesWritten = [_outputStream write:readBytes maxLength:lengthOfDataToWrite];
        if (bytesWritten > 0) {
            self.currentDataOffset += bytesWritten;
            if (self.currentDataOffset == dataLength) {
                [_dataWriteQueue removeObjectAtIndex:0];
                self.currentDataOffset = 0;
            }
        }
    }
}

- (void)dispatchJSONDictionary: (NSDictionary*) JSONDict {
    NSString *command = [JSONDict valueForKey:@"command"];
    
    //dispatching signin result
    if ([command isEqualToString:@"signin"]) {
        NSString *result = [JSONDict valueForKey:@"result"];
        if ([result isEqualToString:@"succeed"]) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"signin succeed"
             object:self];
        }
        else if([result isEqualToString:@"failed"]) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"signin failed"
             object:self userInfo:JSONDict];
        }
    }
    
    //dispatching signup result
    else if ([command isEqualToString:@"signup"]) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"signup failed"
         object:self
         userInfo:JSONDict];
    }
    
    //dispatch getUserInfo
    else if ([command isEqualToString:@"getUserInfo"]) {
        NSDictionary *usrDict = (NSDictionary*)[JSONDict objectForKey:@"user"];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"getUserInfo"
         object:self
         userInfo:usrDict];
    }
    
    //dispatch getPlayerInfo
    else if ([command isEqualToString:@"getPlayerInfo"]) {
        NSDictionary *playerDict = (NSDictionary*)[JSONDict objectForKey:@"player"];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"getPlayerInfo"
         object:self
         userInfo:playerDict];
    }
    
    //dispatch command_recieved
    else if ([command isEqualToString:@"command_recieved"]) {

    }
    
    //dispatch synchronize_questions
    else if ([command isEqualToString:@"synchronize_questions"]) {
        NSDictionary *questionsDict = (NSDictionary*)[JSONDict objectForKey:@"questions"];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"synchronize_questions"
         object:self
         userInfo:questionsDict];
    }
    
    else {
        NSLog(@"Unknown command recieved by client: %@", command);
    }
}

- (void)sendMessageSignInWithUsername:(NSString *)aUsername
                          andPassword:(NSString *)aPassword {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"signin", @"command",
                          aUsername, @"username",
                          aPassword, @"password",
                          nil];
    [[Client instance] pushMessageToQueue:dict];
}

- (void)sendMessageSignUpWithUsername:(NSString *)aUsername
                          andPassword:(NSString *)aPassword
                             andEmail:(NSString *)anEmail {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"signup", @"command",
                          aUsername, @"username",
                          aPassword, @"password",
                          anEmail,   @"email",
                          nil];
    [[Client instance] pushMessageToQueue:dict];
}

- (void)sendMessageGetUserInfo:(NSString *)aUsername {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"getUserInfo", @"command",
                          aUsername, @"username",
                          nil];
    [[Client instance] pushMessageToQueue:dict];
}

- (void)sendMessageGetPlayerInfo:(NSString *)aUsername {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"getPlayerInfo", @"command",
                          aUsername, @"username",
                          nil];
    [[Client instance] pushMessageToQueue:dict];
}

- (void)sendMessagePostUserAnswer:(UserAnswer *)userAnswer {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"postUserAnswer", @"command",
                          [userAnswer toJSON], @"userAnswer",
                          nil];
    [[Client instance] pushMessageToQueue:dict];
}

- (void)onInputStreamEventEndEncountered {
    NSLog(@"Connection closed by Server. Seems, we are down. Sorry =(");
    [_inputStream close];
}

- (void)onInputStreamEventErrorOccured {
    //can't connect to host - server is down
    NSLog(@"Error occured in Input Stream:\n");
    NSLog(@"%@",[[_inputStream streamError] localizedDescription]);
}

- (void)sendMessageFindMatch {
    NSString *playerName = [[Player instance] name];
    NSString *commandFindMatch = [NSString stringWithFormat:@"find_match"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          commandFindMatch, @"command",
                          playerName, @"player_name",
                          nil];
    [[Client instance] pushMessageToQueue:dict];
}

- (void)sendMessageUpdateRound:(Round *)round {
    NSString *command = [NSString stringWithFormat:@"update_round"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          command, @"command",
                          [round toJSON], @"round",
                          nil];
    [[Client instance] pushMessageToQueue:dict];
}

- (void)sendMessageUpdateMatch:(Match *)match {
    NSString *command = [NSString stringWithFormat:@"update_match"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          command, @"command",
                          [match toJSON], @"match",
                          nil];
    [[Client instance] pushMessageToQueue:dict];
}

- (void)sendMessageUpdateUser:(User *)user {
    NSString *command = [NSString stringWithFormat:@"update_user"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          command, @"command",
                          [user toJSON], @"match",
                          nil];
    [[Client instance] pushMessageToQueue:dict];
}

- (void)sendMessageSynchronizeQuestions {
    NSMutableArray *localQuestions = [[Database instance] localQuestions];
    NSMutableArray *questionIDs = [[NSMutableArray alloc] init];
    for (Question *question in localQuestions) {
        [questionIDs addObject:[NSNumber numberWithLong:question.ID]];
    }
    
    NSNumber *questionImageWidth = [NSNumber numberWithLong: 568];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"synchronize_questions", @"command",
                          questionIDs, @"questions_IDs",
                          questionImageWidth, @"question_image_width",
                          nil];
    [[Client instance] pushMessageToQueue:dict];
}


- (BOOL)connected {
    if (
        ([_inputStream streamStatus] == NSStreamStatusNotOpen)||
        ([_inputStream streamStatus] == NSStreamStatusAtEnd) ||
        ([_inputStream streamStatus] == NSStreamStatusClosed) ||
        ([_inputStream streamStatus] == NSStreamStatusError))
    {
        return NO;
    }
    else if (
             ([_outputStream streamStatus] == NSStreamStatusNotOpen)||
             ([_outputStream streamStatus] == NSStreamStatusAtEnd) ||
             ([_outputStream streamStatus] == NSStreamStatusClosed) ||
             ([_outputStream streamStatus] == NSStreamStatusError))
    {
        return NO;
    }
    return YES;
}

- (void)onInputStreamEventHasBytesAvailable:(NSStream *)aStream {
    //defining buffer, cleaning it
    uint8_t buffer[BUFFER_SIZE];
    bzero(buffer, sizeof(buffer));
    int len;
    NSError *error;
    
    //reading bytes into buffer
    len = (int)[_inputStream read:buffer maxLength:sizeof(buffer)];
    if (len > 0) {
        [_data appendBytes:buffer length:len];
    }
    else {
        NSLog(@"NSInputStream read 0 bytes: Probably server is OFF.");
    }
    
    //checking if _data is overflowing MAX_BUFFER_SIZE
    float current_buffer_size = [_data length];
    if (current_buffer_size > MAX_BUFFER_SIZE) {
        NSLog(@"internal buffer is overflow: %2.fkB / %2.fkB",
              (float)current_buffer_size / 1024.0, (float)MAX_BUFFER_SIZE / 1024.0);
        return;
    }
    
    //creating UTF8 String from raw bytes
    NSString *utf8String = [[NSString alloc] initWithBytes:[_data bytes]
                                                    length:[_data length] encoding:NSUTF8StringEncoding];
    
    int ext_bytes_read = 0;
    while (!utf8String) {
        if (ext_bytes_read > 5) {
            NSLog(@"Can't decode input byte array into UTF8.");
            return;
        }
        else {
            uint8_t byte[1];
            [_inputStream read:byte maxLength:1];
            [_data appendBytes:byte length:1];
            utf8String = [NSString stringWithUTF8String:[_data bytes]];
            ext_bytes_read++;
        }
    }
    
    //get separate commands from internal buffer
    NSMutableArray *commandsArray = [[utf8String componentsSeparatedByString:@"ENDMSG"] mutableCopy];
    //removing ENDMSG from the tail of the string
    if ([[commandsArray lastObject] isEqualToString:@""]) {
        [commandsArray removeLastObject];
    }
        
    for (int i = 0; i < [commandsArray count]; i++) {
        //parsing NSData to JSON Dictionary
        NSData *data = [[commandsArray objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding];
        //filling up NSData with buffer
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions error:&error];
        if(error) {
            if (i == 0) {
                if ([commandsArray count] > 1) {
                    NSLog(@"CORRUPTED DATA IN JSON!!!");
                    return;
                }
                else {
                    return;
                }
            }
            else {
                //if that's the last object
                if ([[commandsArray lastObject] isEqualToString:[commandsArray objectAtIndex:i]]) {
                    //cleaning internal buffer
                    [_data setLength:0];
                    //inserting possibly not-ended data
                    NSRange range;
                    range.location = 0;
                    range.length = [data length];
                    [_data replaceBytesInRange:range withBytes:[data bytes]];
                    return;
                }
            }
        }
        else {
            //cleaning internal buffer
            [_data setLength:0];
            //dispatching message
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dispatchJSONDictionary:dict];
            });
        }
    }
}

@end
