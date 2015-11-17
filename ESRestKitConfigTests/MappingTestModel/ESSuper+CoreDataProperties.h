//
//  ESSuper+CoreDataProperties.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 16/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ESSuper.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESSuper (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *identifier;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSDate *updatedAt;

@end

NS_ASSUME_NONNULL_END
