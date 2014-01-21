//
//  CBGaspPlaces.m
//  gasp
//
//  Created by Mark Prichard on 1/15/14.
//  Copyright (c) 2014 CloudBees. All rights reserved.
//

#import "CBGaspPlaces.h"

#define GOOGLE_API_KEY @"AIzaSyD8RPFcX_YY3-M21yGGaww2_NBPLHsjU5o"
#define GOOGLE_PLACES_SEARCH @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@&radius=%@&types=%@&sensor=true&key=%@"
#define GOOGLE_PLACES_DETAILS @"https://maps.googleapis.com/maps/api/place/details/json?&sensor=true&key=%@&reference=%@"
#define GOOGLE_PLACES_EVENT_ADD @"https://maps.googleapis.com/maps/api/place/event/add/json?&sensor=true&key=%@"
#define GOOGLE_PLACES_EVENT_DELETE @"https://maps.googleapis.com/maps/api/place/event/delete/json?&sensor=true&key=%@"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@implementation CBGaspPlaces

void(^getGooglePlacesCallback)(NSDictionary *result, NSError *error);
void(^getPlaceDetailsCallback)(NSDictionary *result, NSError *error);

+ (CBGaspPlaces *)sharedNetworkClient {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void) getGooglePlaces:(NSString *)googleType
           withLocation:(NSString *) location
             withRadius:(NSString *) radius
           withCallback:(CBCompletionBlock)callback {
 
    NSString *url = [NSString stringWithFormat:GOOGLE_PLACES_SEARCH, location, radius, googleType, GOOGLE_API_KEY];
    NSURL *googleRequestURL = [[NSURL alloc] initWithString:[url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSLog(@"%@", googleRequestURL);
    
    // Set callback with results/error data
    //getGooglePlacesCallback = [callback copy];
    getGooglePlacesCallback = callback;
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(placesSearchResult:) withObject:data waitUntilDone:YES];
    });
}

-(void)placesSearchResult:(NSData *)responseData {
    if (responseData == nil)
        NSLog(@"%@", @"Google Places API call Failed");

    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
    getGooglePlacesCallback(json, error);
}

-(void) getPlaceDetails:(NSString *) reference
           withCallback:(CBCompletionBlock)callback {
    
    NSString *url = [NSString stringWithFormat:GOOGLE_PLACES_DETAILS, GOOGLE_API_KEY, reference];
    NSURL *googleRequestURL = [[NSURL alloc] initWithString:[url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSLog(@"%@", googleRequestURL);
    
    // Set callback with results/error data
    getPlaceDetailsCallback = callback;
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(placesDetailsResult:) withObject:data waitUntilDone:YES];
    });
}

-(void)placesDetailsResult:(NSData *)responseData {
    if (responseData == nil)
        NSLog(@"%@", @"Google Places API call Failed");
    
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    NSDictionary* details = [json objectForKey:@"result"];
    
    getPlaceDetailsCallback(details, error);
}

@end
