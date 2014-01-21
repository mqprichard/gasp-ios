//
//  CBGaspPlaces.h
//  gasp
//
//  Created by Mark Prichard on 1/15/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

typedef void (^CBCompletionBlock)(NSDictionary *data, NSError *error);

@interface CBGaspPlaces : NSObject
-(void) getPlaceDetails:(NSString *) reference;
-(void) getGooglePlaces:(NSString *) googleType
           withLocation:(NSString *) location
             withRadius:(NSString *) radius
           withCallback:(CBCompletionBlock) callback;
+ (CBGaspPlaces *)sharedNetworkClient;
@end
