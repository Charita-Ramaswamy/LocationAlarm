//
//  SaveOrUpdateDataModel.m
//  LocationApp
//
//  Created by Charita R on 18/04/17.
//  Copyright © 2017 Charita R. All rights reserved.
//

#import "SaveOrUpdateDataModel.h"
//#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@implementation SaveOrUpdateDataModel

-(void)saveDestinationPlaceInfo:(NSString *)placeName withAddress:(NSString *)placeAdd withLat:(NSNumber*)latitude withLong:(NSNumber *)longitude{
   
    NSManagedObjectContext *managedObjectContext = [((AppDelegate *)[[UIApplication sharedApplication] delegate]) managedObjectContext];
    NSError* error;
    
    @try{
        NSManagedObject *placeData = [NSEntityDescription insertNewObjectForEntityForName:@"DestinationDetails" inManagedObjectContext:managedObjectContext];
        [placeData setValue:placeName forKey:@"name"];
        [placeData setValue:placeAdd forKey:@"address"];
        [placeData setValue:latitude forKey:@"latitude"];
        [placeData setValue:longitude forKey:@"longitude"];
        
        if(![managedObjectContext save:&error]){
            NSLog(@"Error! %@", error.description);
        }
    }@catch (NSException *exception) {
        NSLog(@"Exception: %@", exception.description);
    }
}


-(int)fetchAllPlaces{
    NSManagedObjectContext *managedObjectContext = [((AppDelegate *)[[UIApplication sharedApplication] delegate]) managedObjectContext];
    NSEntityDescription *userProfile = [NSEntityDescription entityForName:@"DestinationDetails" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:userProfile];
    
    NSManagedObject *managedObject = nil;
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    int totalNoOfRecords = (int)[objects count];
    return totalNoOfRecords;
}

-(NSArray*)getAllPastDestinationDetails{
    NSManagedObjectContext *managedObjectContext = [((AppDelegate *)[[UIApplication sharedApplication] delegate]) managedObjectContext];
    NSEntityDescription *userProfile = [NSEntityDescription entityForName:@"DestinationDetails" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:userProfile];
    
    NSManagedObject *managedObject = nil;
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];

    return objects;
}

@end
