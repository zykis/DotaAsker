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
    id entity = [cache obtain:entityID];
    if (entity == nil) {
        NSData* JSONData = [transport obtain:entityID];
        NSError* error;
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:&error];
        if (!error) {
            entity = [parser parse:jsonDict];
            if (entity != nil) {
                [cache append:entity];
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
    NSData* data = [transport obtainAll];
    NSError* error;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (!error) {
        NSArray* array = [parser parseAll:jsonDict];
        [cache appendEntities:array];
        return array;
    }
    else {
        return nil;
    }
    
}

- (id)update:(id)entity {
    NSDictionary* jsonDict = [parser encode:entity];
    NSError* error;
    NSData* entityData = [NSJSONSerialization dataWithJSONObject:jsonDict options:kNilOptions error:&error];
    if (!error) {
        NSData* data = [transport update:entityData];
        jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!error) {
            id updated = [parser parse:jsonDict];
            [cache update:updated];
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
    NSDictionary* jsonDict = [parser encode:entity];
    NSError* error;
    NSData* entityData = [NSJSONSerialization dataWithJSONObject:jsonDict options:kNilOptions error:&error];
    if (!error) {
        NSData* data = [transport create:entityData];
        jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!error) {
            id created = [parser parse:jsonDict];
            [cache append:created];
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
    [cache remove:entityID];
    [transport remove:entityID];
}

@end
