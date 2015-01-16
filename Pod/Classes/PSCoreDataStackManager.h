//
//  PSCoreDataStackManager.h
//  
//
//  Created by Pedro Sebastião on 13/12/13.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// NOTE: this fixes a bug with ordered one-to-many relations on Core Data
//       you will need to have KCOrderedAccessorFix in your project in order to apply this fix
//       https://github.com/CFKevinRef/KCOrderedAccessorFix
#define COREDATA_USE_ORDERED_SET_FIX 0

@interface PSCoreDataStackManager : NSObject

// set to your NSManagedObject subclass prefix, default is empty
@property (copy, nonatomic) NSString *managedObjectClassPrefix;

// default keys used for sorting on fetch requests
@property (copy, nonatomic) NSArray *defaultSortKeys;

// default keys used for section key path on fetch results controller
@property (copy, nonatomic) NSArray *defaultSectionKeyPaths;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)sharedManager;

@end
