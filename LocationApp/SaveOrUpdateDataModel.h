//
//  SaveOrUpdateDataModel.h
//  LocationApp
//
//  Created by Charita R on 18/04/17.
//  Copyright © 2017 Charita R. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SaveOrUpdateDataModel : NSObject

-(void)saveDestinationPlaceInfo:(NSString*)placeName withAddress:(NSString*)placeAdd withLat:(NSNumber*)latitude withLong:(NSNumber*)longitude;
-(int)fetchAllPlaces;
-(NSArray*)getAllPastDestinationDetails;

@end
