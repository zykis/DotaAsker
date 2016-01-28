//
//  AbstractService.m
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "AbstractService.h"

@implementation AbstractService

@synthesize cache;
@synthesize transport;
@synthesize parser;

- (id)obtain:(unsigned long long)entityID {
    id entity = [self.cache obtain:entityID];
    if (entity == nil) {
        NSData* JSONData = [self.transport obtain:entityID];
        if (!JSONData) {
            return nil;
        }
        NSError* error;
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:&error];
        if (!error) {
            entity = [self.parser parse:jsonDict];
            if (entity != nil) {
                [self.cache append:entity];
            }
            return entity;
        }
        else {
            return nil;
        }
    }
    else {
        return entity;
    }
}

- (NSArray*)obtainAll {
    NSData* data = [self.transport obtainAll];
    if (!data) {
        return nil;
    }
    NSError* error;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (!error) {
        NSArray* array = [self.parser parseAll:jsonDict];
        [self.cache appendEntities:array];
        return array;
    }
    else {
        return nil;
    }
    
}

- (id)update:(id)entity {
    NSDictionary* jsonDict = [self.parser encode:entity];
    if (!jsonDict) {
        return nil;
    }
    NSError* error;
    NSData* entityData = [NSJSONSerialization dataWithJSONObject:jsonDict options:kNilOptions error:&error];
    if (!error) {
        NSData* data = [self.transport update:entityData];
        if (!data) {
            return nil;
        }
        jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!error) {
            id updated = [self.parser parse:jsonDict];
            [self.cache update:updated];
            return updated;
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}

- (id)create:(id)entity {
    NSDictionary* jsonDict = [self.parser encode:entity];
    if (!jsonDict) {
        return nil;
    }
    NSError* error;
    NSData* entityData = [NSJSONSerialization dataWithJSONObject:jsonDict options:kNilOptions error:&error];
    if (!error) {
        NSData* data = [self.transport create:entityData];
        if (!data) {
            return nil;
        }
        jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!error) {
            id created = [self.parser parse:jsonDict];
            [self.cache append:created];
            return created;
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}

- (void)remove:(unsigned long long)entityID {
    [self.cache remove:entityID];
    [self.transport remove:entityID];
}

@end
