//
//  Transport.m
//  DotaAsker
//
//  Created by Artem on 17/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "Transport.h"

#define TIMEOUT_SECONDS 5

@implementation Transport

/* {api}/{model}/{id}/{property} */
// {api} = CREATE / GET / UPDATE / DELETE
// {model} = USERANSWER / ANSWER / QUESTION / THEME / ROUND / MATCH / USER / PLAYER

@synthesize transportCompletionBlockData;
@synthesize transportCompletionBlockMessage;
@synthesize messageToSend;

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)websocket:(JFRWebSocket *)socket didReceiveData:(NSData *)data {
    dispatch_async(dispatch_get_global_queue(0, 0),
                   ^{
                       transportCompletionBlockData(data);
                   });
}

- (void)websocket:(JFRWebSocket *)socket didReceiveMessage:(NSString *)string {
    dispatch_async(dispatch_get_global_queue(0, 0),
                   ^{
                       NSLog(@"Message recieved: %@", string);
                       transportCompletionBlockMessage(string);
                   });
}

- (void)sendMessage:(NSString*)message WithComplition:(TransportCompletionBlockMessage)aCompletionBlock {
    NSInteger connectionTimeoutSeconds = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Connection timeout (sec)"] integerValue];
    if(!connectionTimeoutSeconds)
        connectionTimeoutSeconds = 2;//default value
    
    self.transportCompletionBlockMessage = aCompletionBlock;
    //устанавливаем соединение
    JFRWebSocket* sock = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://localhost:1536"] protocols:@[@"data"]];
    self.sock = sock;
    self.sock.delegate = self;
    if([self.sock waitForConnection:connectionTimeoutSeconds] == 0) {
        //отправляем запрос
        [self.sock writeString:message];
    }
    else {
        //нет соединения
        self.transportCompletionBlockMessage = ^(NSString* str){};
    }
}

- (void)sendMessage:(NSString*)message {
    NSInteger connectionTimeoutSeconds = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Connection timeout (sec)"] integerValue];
    if(!connectionTimeoutSeconds)
        connectionTimeoutSeconds = 2;//default value
    
    //устанавливаем соединение
    JFRWebSocket* sock = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://localhost:1536"] protocols:@[@"data"]];
    self.sock = sock;
    self.sock.delegate = self;
    if([self.sock waitForConnection:connectionTimeoutSeconds] == 0) {
        //отправляем запрос
        [self.sock writeString:message];
    }
}

- (NSString*)obtainMessageWithMessage:(NSString *)message {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString __block *msg = nil;
    NSInteger messageTimeoutSeconds = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Message timeout (sec)"] integerValue];
    if(!messageTimeoutSeconds)
        messageTimeoutSeconds = 5;
    
    [self sendMessage:message WithComplition:^(NSString *receivedMessage) {
                 msg = receivedMessage;
                 dispatch_semaphore_signal(semaphore);
             }];
    
    dispatch_time_t timeoutTime = dispatch_time(DISPATCH_TIME_NOW, messageTimeoutSeconds * pow(10,9));
    if(dispatch_semaphore_wait(semaphore, timeoutTime)) {
        NSLog(@"Message timed out");
        self.transportCompletionBlockMessage = ^(NSString* str){};
    }
    
    //отсоединяемся
    [self.sock disconnect];
    return msg;
}















@end