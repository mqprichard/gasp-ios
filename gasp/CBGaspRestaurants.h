//
//  CBNetworkClient.h
//  gasp
//
//  Created by Mark Prichard on 1/8/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBGaspRestaurants : NSObject

- (NSString *) stringHttpGetContentsAtURL:(NSString *)url;
- (NSDictionary *) parseJSON:(NSString *)responseString;
- (NSArray *) parseJSONList:(NSString *)responseString;
- (NSArray *) listRestaurants:(NSString *)host;
- (NSString *) makeURL:(NSString *)url withPath:(NSString *)path;
+ (CBGaspRestaurants *)sharedNetworkClient;

@end
