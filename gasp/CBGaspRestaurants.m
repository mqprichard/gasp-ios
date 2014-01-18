//
//  CBNetworkClient.m
//  gasp
//
//  Created by Mark Prichard on 1/8/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

#import "CBGaspRestaurants.h"

@implementation CBGaspRestaurants

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

- (NSArray *) listRestaurants:(NSString *)host {
    NSString *data = [self stringHttpGetContentsAtURL:[self makeURL: host withPath:@"restaurants"]];
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
            NSString* name = [[object objectAtIndex:i] valueForKey:@"name"];
            NSString* placesId = [[object objectAtIndex:i] valueForKey:@"placesId"];
            NSLog(@"RESTAURANT Name: %@, Places Id: %@", name, placesId);
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

+ (CBGaspRestaurants *)sharedNetworkClient {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end
