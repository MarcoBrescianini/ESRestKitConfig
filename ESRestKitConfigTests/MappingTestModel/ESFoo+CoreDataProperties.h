//
//  ESFoo+CoreDataProperties.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 04/11/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ESFoo.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESFoo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *info;
@property (nullable, nonatomic, retain) NSString *lastname;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *barId;
@property (nullable, nonatomic, retain) ESBar *bar;
@property (nullable, nonatomic, retain) NSSet<ESMultiple *> *mutliples;

@end

@interface ESFoo (CoreDataGeneratedAccessors)

- (void)addMutliplesObject:(ESMultiple *)value;
- (void)removeMutliplesObject:(ESMultiple *)value;
- (void)addMutliples:(NSSet<ESMultiple *> *)values;
- (void)removeMutliples:(NSSet<ESMultiple *> *)values;

@end

NS_ASSUME_NONNULL_END
