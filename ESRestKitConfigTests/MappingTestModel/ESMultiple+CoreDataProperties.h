//
//  ESMultiple+CoreDataProperties.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 26/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ESMultiple.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESMultiple (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *detail;
@property (nullable, nonatomic, retain) ESFoo *foo;

@end

NS_ASSUME_NONNULL_END
