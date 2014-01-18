//
//  CBGaspUsers.m
//  gasp
//
//  Created by Mark Prichard on 1/9/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

#import "CBGaspUsers.h"
#import <Foundation/Foundation.h>

@implementation CBGaspUsers

- (NSString *) stringHttpGetContentsAtURL:(NSString *)url {
    NSURL *site = [NSURL URLWithString:url];
    return [NSString stringWithContentsOfURL:site encoding:NSUTF8StringEncoding error:NULL];
}


- (NSString *) makeURL:(NSString *)url withPath:(NSString *)path {
    return [url stringByAppendingPathComponent:path];
}

/*
 * fetch a (json) list of restaurants
 */

- (NSArray *) listUsers:(NSString *)host {
    NSString *data = [self stringHttpGetContentsAtURL:[self makeURL: host withPath:@"users"]];
    //NSLog(@"%@\n", data);
    return [self parseJSONList:data];
}

/*
 * Convert JSON to an array we can use.
 */

- (NSArray *) parseJSONList:(NSString *)responseString {
    if (responseString == nil) return nil;
    NSData* data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if([object isKindOfClass:[NSArray class]]) {
        
        for (int i = 0; i < [object count]; i++) {
            NSString* url = [[object objectAtIndex:i] valueForKey:@"url"];
            NSString* name = [[object objectAtIndex:i] valueForKey:@"name"];
            NSLog(@"USER Url: %@, Name: %@", url, name);
        }
        
        return (NSArray *) object;
    } else {
        return nil;
    }
}

/*
 * Convert JSON to Dictionary we can use
 */

- (NSDictionary *) parseJSON:(NSString *)responseString {
    if (responseString == nil) return nil;
    NSData* data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if([object isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *) object;
    } else {
        return nil;
    }
}

/*
 * We only need one instance of this network client for the app.
 */

+ (CBGaspUsers *)sharedNetworkClient {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


@end
