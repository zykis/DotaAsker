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
// {model} = UserAnswer / Answer / Question / Theme / Round / Match / User / Player

@synthesize transportCompletionBlockData;
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

- (void)sendMessage:(NSString*)message WithComplition:(TransportCompletionBlockData)aCompletionBlock {
    self.transportCompletionBlockData = aCompletionBlock;
    //устанавливаем соединение
    JFRWebSocket* sock = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://localhost:1536"] protocols:@[@"data"]];
    self.sock = sock;
    self.sock.delegate = self;
    [self.sock connect];
    
    //отправляем запрос
    [self.sock writeString:message];
}

- (NSData*)obtainDataWithMessage:(NSString *)message {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSData __block *data = nil;
    dispatch_time_t timeoutTime = dispatch_time(DISPATCH_TIME_NOW, TIMEOUT_SECONDS * 10^9);
    
    [self sendMessage:message WithComplition:^(NSData *receivedData) {
                 data = receivedData;
                 dispatch_semaphore_signal(semaphore);
             }];
    
    
    if(dispatch_semaphore_wait(semaphore, timeoutTime) != 0) {
        NSLog(@"timed out");
    }
    
    //отсоединяемся
    [self.sock disconnect];
    return data;
}















@end