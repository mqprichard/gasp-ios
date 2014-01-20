//
//  CBAddRestaurantDelegate.m
//  gasp
//
//  Created by Mark Prichard on 1/19/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

#import "CBAddRestaurantDelegate.h"
#import "CBGaspRestaurants.h"
#import "CBDeleteRestaurantDelegate.h"

static NSString *const HOST = @"http://gasp2.partnerdemo.cloudbees.net";

@implementation CBAddRestaurantDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Received: %@", response);
    NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
    NSLog(@"Location: %@", [headers objectForKey:@"Location"]);
    
    CBGaspRestaurants *client = [[CBGaspRestaurants alloc] init];
    CBDeleteRestaurantDelegate *callback = [[CBDeleteRestaurantDelegate alloc] init];
    [client DeleteRestaurant:HOST withDelegate:callback withLocation:[headers objectForKey:@"Location"]];
}

@end
