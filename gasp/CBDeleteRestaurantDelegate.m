//
//  CBDeleteRestaurantDelegate.m
//  gasp
//
//  Created by Mark Prichard on 1/19/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

#import "CBDeleteRestaurantDelegate.h"

@implementation CBDeleteRestaurantDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Received: %@", response);
}
@end
