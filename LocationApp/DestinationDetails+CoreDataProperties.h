//
//  DestinationDetails+CoreDataProperties.h
//  LocationApp
//
//  Created by Charita R on 18/04/17.
//  Copyright © 2017 Charita R. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DestinationDetails.h"

NS_ASSUME_NONNULL_BEGIN

@interface DestinationDetails (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;

@end

NS_ASSUME_NONNULL_END
