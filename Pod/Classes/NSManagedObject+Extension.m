//
//  NSManagedObject+Extension.m
//  
//
//  Created by Pedro Sebastião on 12/12/13.
//

#import "NSManagedObject+Extension.h"
#import "PSCoreDataStackManager.h"

#define CORE_DATA_CLASS_PREFIX ([PSCoreDataStackManager sharedManager].managedObjectClassPrefix)

@interface NSObject (JSONRepresentation)

- (id)jsonRepresentation;

@end

@implementation NSManagedObject (Extension)


- (id)initAndInsertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    return [self initWithEntity:[NSEntityDescription entityForName:[[self class] entityName]
                                            inManagedObjectContext:context]
 insertIntoManagedObjectContext:context];
}

- (id)initWithDefaultManagedObjectContext {
    return [self initAndInsertIntoManagedObjectContext:[NSManagedObject managedObjectContext]];
}

+ (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *moc = [PSCoreDataStackManager sharedManager].managedObjectContext;
    return moc;
}

+ (NSString *)entityName {
    NSString *entityName = NSStringFromClass(self);
    if ([entityName hasPrefix:CORE_DATA_CLASS_PREFIX]) {
        entityName = [entityName substringFromIndex:[CORE_DATA_CLASS_PREFIX length]];
    }
    return entityName;
}

+ (NSEntityDescription *)entityDescription
{
    NSString *entityName = [self entityName];
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    
    return entity;
}

+ (NSFetchRequest *)fetchRequest
{
    return [self fetchRequestWithPredicate:nil];
}

+ (NSFetchRequest *)fetchRequestWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [self entityDescription];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;
    
    NSArray *entityAttributes = fetchRequest.entity.attributesByName.allKeys;
    
    NSMutableArray *mutableSortDescriptors = [[NSMutableArray alloc] init];
    for (NSString *sortKey in [PSCoreDataStackManager sharedManager].defaultSortKeys) {
        if ([entityAttributes containsObject:sortKey]) {
            [mutableSortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:YES]];
        }
    }
    fetchRequest.sortDescriptors = [mutableSortDescriptors copy];
    
    return fetchRequest;
}


+ (NSFetchedResultsController *)fetchedResultsController {
    NSFetchRequest *fetchRequest = [self fetchRequest];
    
    return [self fetchedResultsControllerWithFetchRequest:fetchRequest];
}


+ (NSFetchedResultsController *)fetchedResultsControllerWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [self fetchRequest];
    fetchRequest.predicate = predicate;
    
    return [self fetchedResultsControllerWithFetchRequest:fetchRequest];
}

+ (NSFetchedResultsController *)fetchedResultsControllerWithSortDescriptor:(NSSortDescriptor *)sortDescriptor
{
    return  [self fetchedResultsControllerWithSortDescriptors:@[sortDescriptor]];
}

+ (NSFetchedResultsController *)fetchedResultsControllerWithSortDescriptors:(NSArray *)sortDescriptors
{
    NSFetchRequest *fetchRequest = [self fetchRequest];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    return [self fetchedResultsControllerWithFetchRequest:fetchRequest];
}

+ (NSFetchedResultsController *)fetchedResultsControllerWithFetchRequest:(NSFetchRequest *)fetchRequest
{
    NSString *sectionNameKeyPath = nil;
    NSArray *entityAttributes = fetchRequest.entity.attributesByName.allKeys;
    
    for (NSString *keyPath in [PSCoreDataStackManager sharedManager].defaultSectionKeyPaths) {
        if ([entityAttributes containsObject:keyPath]) {
            sectionNameKeyPath = keyPath;
            break;
        }
    }
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]
                                              initWithFetchRequest:fetchRequest
                                              managedObjectContext:[self managedObjectContext]
                                              sectionNameKeyPath:sectionNameKeyPath
                                              cacheName:nil];
    
    return controller;
}

+ (NSArray *)fetchAll {
    NSManagedObjectContext *managedObjectContext = [NSManagedObject managedObjectContext];
    
    return [self fetchAllInManagedObjectContext:managedObjectContext];
}

+ (NSArray *)fetchAllInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    if (fetchResults == nil) {
        // Handle the error.
    }
    
    return fetchResults;
}

+ (NSArray *)fetchWithPredicate:(NSPredicate *)predicate {
    NSManagedObjectContext *managedObjectContext = [NSManagedObject managedObjectContext];
    
    return [self fetchWithPredicate:predicate inManagedObjectContext:managedObjectContext];
}

+ (NSArray *)fetchWithPredicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    if (fetchResults == nil) {
        // Handle the error.
    }
    
    return fetchResults;
}

+ (NSArray *)fetchWithSortDescriptor:(NSSortDescriptor *)sortDescriptor {
    NSManagedObjectContext *managedObjectContext = [NSManagedObject managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    if (fetchResults == nil) {
        // Handle the error.
    }
    
    return fetchResults;
}

+ (NSArray *)fetchWithSortDescriptors:(NSArray *)sortDescriptors {
    NSManagedObjectContext *managedObjectContext = [NSManagedObject managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    if (fetchResults == nil) {
        // Handle the error.
    }
    
    return fetchResults;
}


#pragma mark -
#pragma mark Find All Methods

+ (NSArray *)findAllWithPredicate:(NSPredicate *)predicate {
    NSArray *results = [self fetchWithPredicate:predicate inManagedObjectContext:[self managedObjectContext]];
    
    return results;
}

+ (NSArray *)findAllWithValue:(id)value forKey:(NSString *)key {
    NSString *predicateString = [NSString stringWithFormat:@"%@ == %%@", key];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString, value];
    
    return [self findAllWithPredicate:predicate];
}

+ (NSArray *)findAllWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION {
    va_list args;
    va_start(args, firstObject);
    id objects = [self findAllWithFirstObject:firstObject arguments:args];
    va_end(args);
    return objects;
}
+ (NSArray *)findAllWithFirstObject:(id)firstObject arguments:(va_list)args {
    
    NSMutableArray *objects = [NSMutableArray array];
    NSMutableArray *keys = [NSMutableArray array];
    
    NSInteger i = 0;
    for (id arg = firstObject; arg != nil; arg = va_arg(args, id))
    {
        if (i % 2 == 0) {
            // objects
            [objects addObject:arg];
        } else {
            // keys
            [keys addObject:arg];
        }
        i++;
    }
    NSString *predicateString = @"";
    
    for (id key in keys) {
        predicateString = [predicateString stringByAppendingFormat:@"%@ == %%@ AND ", key];
    }
    predicateString = [predicateString substringToIndex:[predicateString length] - 5];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString argumentArray:objects];
    
    return [self findAllWithPredicate:predicate];
}


#pragma mark -
#pragma mark Find One Methods


+ (instancetype)findWithPredicate:(NSPredicate *)predicate {
    NSArray *results = [self fetchWithPredicate:predicate inManagedObjectContext:[self managedObjectContext]];
    
    if ([results count] > 0) {
        return [results lastObject];
    } else {
        return nil;
    }
}

+ (instancetype)findWithValue:(id)value forKey:(NSString *)key {
    NSString *predicateString = [NSString stringWithFormat:@"%@ == %%@", key];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString, value];
    
    return [self findWithPredicate:predicate];
}

+ (instancetype)findWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION {
    va_list args;
    va_start(args, firstObject);
    id object = [self findWithFirstObject:firstObject arguments:args];
    va_end(args);
    return object;
}

+ (instancetype)findWithFirstObject:(id)firstObject arguments:(va_list)args {
    
    NSMutableArray *objects = [NSMutableArray array];
    NSMutableArray *keys = [NSMutableArray array];
    
    NSInteger i = 0;
    for (id arg = firstObject; arg != nil; arg = va_arg(args, id))
    {
        if (i % 2 == 0) {
            // objects
            [objects addObject:arg];
        } else {
            // keys
            [keys addObject:arg];
        }
        i++;
    }
    NSString *predicateString = @"";
    
    for (id key in keys) {
        predicateString = [predicateString stringByAppendingFormat:@"%@ == %%@ AND ", key];
    }
    predicateString = [predicateString substringToIndex:[predicateString length] - 5];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString argumentArray:objects];
    
    return [self findWithPredicate:predicate];
}

#pragma mark -
#pragma mark Find or Create Methods

+ (instancetype)findOrCreateWithValue:(id)value forKey:(NSString *)key {
    return [self findOrCreateWithValue:value
                                forKey:key
                inManagedObjectContext:[self managedObjectContext]];
}

+ (instancetype)findOrCreateWithValue:(id)value forKey:(NSString *)key inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    NSString *predicateString = [NSString stringWithFormat:@"%@ == %%@", key];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString, value];
    
    NSArray *results = nil;
    
    @try {
        results = [self fetchWithPredicate:predicate inManagedObjectContext:managedObjectContext];
    }
    @catch (NSException *exception) {
        // Handle error
    }
    
    if ([results count] > 1) {
        // not unique, returning last object
        return [results lastObject];
    } else if ([results count] == 0) {
        // create new object and return it
        NSManagedObject *newObject = [self createInManagedObjectContext:managedObjectContext];
        [newObject setValue:value forKey:key];
        return newObject;
    } else {
        // return found object
        return [results lastObject];
    }
    
}


+ (instancetype)findOrCreateWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION {
    va_list args;
    va_start(args, firstObject);
    id object = [self findOrCreateWithFirstObject:firstObject arguments:args];
    va_end(args);
    return object;
}

+ (instancetype)findOrCreateWithFirstObject:(id)firstObject arguments:(va_list)args {
    return [self findOrCreateInManagedObjectContext:[self managedObjectContext]
                                        firstObject:firstObject
                                          arguments:args];
}

+ (instancetype)findOrCreateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                      withObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION {
    va_list args;
    va_start(args, firstObject);
    id object = [self findOrCreateInManagedObjectContext:managedObjectContext firstObject:firstObject arguments:args];
    va_end(args);
    return object;
    
}

+ (instancetype)findOrCreateInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                             firstObject:(id)firstObject
                               arguments:(va_list)args {
    
    
    
    NSMutableArray *objects = [NSMutableArray array];
    NSMutableArray *keys = [NSMutableArray array];
    
    NSInteger i = 0;
    for (id arg = firstObject; arg != nil; arg = va_arg(args, id))
    {
        if (i % 2 == 0) {
            // objects
            [objects addObject:arg];
        } else {
            // keys
            [keys addObject:arg];
        }
        i++;
    }
    NSString *predicateString = @"";
    
    for (id key in keys) {
        predicateString = [predicateString stringByAppendingFormat:@"%@ == %%@ AND ", key];
    }
    predicateString = [predicateString substringToIndex:[predicateString length] - 5];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString argumentArray:objects];
    
    NSArray *results = nil;
    
    @try {
        results = [self fetchWithPredicate:predicate inManagedObjectContext:managedObjectContext];
    }
    @catch (NSException *exception) {
        
    }
    
    if ([results count] > 1) {
        return [results lastObject];
    } else if ([results count] == 0) {
        // create a new object and return it
        NSManagedObject *newObject = [self createInManagedObjectContext:managedObjectContext];
        [newObject setValuesForKeysWithDictionary:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
        return newObject;
    } else {
        return [results lastObject];
    }
    
}

#pragma mark -
#pragma mark Lifecycle Methods

+ (instancetype)createInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    // create a new object and return it
    NSManagedObject *newObject = [[self alloc] initAndInsertIntoManagedObjectContext:managedObjectContext];
    return newObject;
}

+ (instancetype)create {
    // create a new object and return it
    NSManagedObject *newObject = [[self alloc] initWithDefaultManagedObjectContext];
    return newObject;
}

- (void)delete {
    [[self managedObjectContext] deleteObject:self];
}

+ (void)deleteAll {
    NSArray *allObjects = [[self class] fetchAll];
    for (NSManagedObject *object in allObjects) {
        [object delete];
    }
}

#pragma mark -
#pragma mark Other Methods

- (NSDictionary *)dictionaryRepresentation:(NSError **)error {
    @try {
        return [self jsonRepresentation];
    }
    @catch (NSException *exception) {
        if (error) {
            *error = [NSError errorWithDomain:exception.reason code:-1 userInfo:nil];
        }
        return nil;
    }
}

- (id)objectInCurrentContext {
    id obj = [[[self class] managedObjectContext] objectWithID:[self objectID]];
    return obj;
}


- (void)refresh
{
    [self.managedObjectContext processPendingChanges];
    NSTimeInterval stalnessInterval = self.managedObjectContext.stalenessInterval;
    self.managedObjectContext.stalenessInterval = 0.0;
    [self.managedObjectContext refreshObject:self mergeChanges:NO];
    self.managedObjectContext.stalenessInterval = stalnessInterval;
}

@end
