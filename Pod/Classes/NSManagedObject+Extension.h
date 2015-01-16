//
//  NSManagedObject+Extension.h
//  
//
//  Created by Pedro Sebastião on 12/12/13.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Extension)

- (id)initAndInsertIntoManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSString *)entityName;
+ (NSEntityDescription *)entityDescription;
+ (NSFetchRequest *)fetchRequest;
+ (NSFetchRequest *)fetchRequestWithPredicate:(NSPredicate *)predicate;

// fetch objects
+ (NSArray *)fetchAll;
+ (NSArray *)fetchWithPredicate:(NSPredicate *)predicate;
+ (NSArray *)fetchWithSortDescriptor:(NSSortDescriptor *)sortDescriptor;
+ (NSArray *)fetchWithSortDescriptors:(NSArray *)sortDescriptors;

+ (NSArray *)fetchAllInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)fetchWithPredicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

// find all objects
+ (NSArray *)findAllWithPredicate:(NSPredicate *)predicate;
+ (NSArray *)findAllWithValue:(id)value forKey:(NSString *)key;
+ (NSArray *)findAllWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
+ (NSArray *)findAllWithFirstObject:(id)firstObject arguments:(va_list)args;

// find a single object
+ (instancetype)findWithPredicate:(NSPredicate *)predicate;
+ (instancetype)findWithValue:(id)value forKey:(NSString *)key;
+ (instancetype)findWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)findWithFirstObject:(id)firstObject arguments:(va_list)args;

// find or create a single object
+ (instancetype)findOrCreateWithValue:(id)value forKey:(NSString *)key;
+ (instancetype)findOrCreateWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)findOrCreateWithFirstObject:(id)firstObject arguments:(va_list)args;

+ (instancetype)findOrCreateWithValue:(id)value forKey:(NSString *)key
     inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)findOrCreateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                      withObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)findOrCreateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                             firstObject:(id)firstObject
                               arguments:(va_list)args;

// create objects
+ (instancetype)create;
+ (instancetype)createInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

// delete objects
- (void)delete;
+ (void)deleteAll;


// simplifies creating a Fetched Results Controller
+ (NSFetchedResultsController *)fetchedResultsController;
+ (NSFetchedResultsController *)fetchedResultsControllerWithPredicate:(NSPredicate *)predicate;
+ (NSFetchedResultsController *)fetchedResultsControllerWithSortDescriptor:(NSSortDescriptor *)sortDescriptor;
+ (NSFetchedResultsController *)fetchedResultsControllerWithSortDescriptors:(NSArray *)sortDescriptors;



// others
- (NSDictionary *)dictionaryRepresentation:(NSError **)error;

// if an NSManagedObject is passed between different threads, use the object returned by this method
// before accessing any data on the object
- (instancetype)objectInCurrentContext;

// forces the object's data to be read from the persistent store coordinatos
- (void)refresh;

@end
