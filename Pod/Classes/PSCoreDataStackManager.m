//
//  PSCoreDataStackManager.m
//
//
//  Created by Pedro Sebastião on 13/12/13.
//

#import "PSCoreDataStackManager.h"

#if COREDATA_USE_ORDERED_SET_FIX 
#import <KCOrderedAccessorFix/NSManagedObjectModel+KCOrderedAccessorFix.h>
#endif

#define MODEL_NAME @"mGovDataModel"

#define SKIP_BACKUP 1 // this sets whether the data store is skipped from iCloud backup
#define USE_LIBRARY_FILE_DOMAIN 0 // set true to use 'Library' instead of 'Documents'

@interface PSCoreDataStackManager ()

- (id)initPrivate;

@property NSHashTable *childrenManagedObjectContexts;

@end

@implementation PSCoreDataStackManager


@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"-[%@ %@] should not be used. Use +[%@ %@] instead", NSStringFromClass([self class]), NSStringFromSelector(_cmd), NSStringFromClass([self class]), NSStringFromSelector(@selector(sharedManager))]
                                 userInfo:nil];
}

- (id)initPrivate
{
    self = [super init];
    if (self) {
        NSHashTable *childrenManagedObjectContexts = [NSHashTable weakObjectsHashTable];
        self.childrenManagedObjectContexts = childrenManagedObjectContexts;
        self.managedObjectClassPrefix = @"";
        self.defaultSortKeys = @[];
        self.defaultSectionKeyPaths = @[];
    }
    return self;
}

+ (instancetype)sharedManager
{
    static id singleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] initPrivate];
    });
    return singleton;
}


/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    // thread "safe" methodology
    if ([NSThread isMainThread]) {
        // if main thread proceed as "usual"
        
        if (__managedObjectContext != nil) {
            return __managedObjectContext;
        }
        
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        
        if (coordinator != nil)
        {
            __managedObjectContext = [[NSManagedObjectContext alloc] init];
            [__managedObjectContext setPersistentStoreCoordinator:coordinator];
            [__managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            
            [[NSNotificationCenter defaultCenter]
             addObserver:self
             selector:@selector(mainManagedObjectContextDidSaveNotification:)
             name:NSManagedObjectContextDidSaveNotification
             object:__managedObjectContext];
        }
        
        return __managedObjectContext;
    } else {
        // if not try to get it from the thread dictionary
        
        NSMutableDictionary *threadDictionary = [NSThread currentThread].threadDictionary;
        NSManagedObjectContext *managedObjectContext = threadDictionary[@"managedObjectContext"];
        
        if (!managedObjectContext) {
            NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
            if (coordinator != nil) {
                managedObjectContext = [[NSManagedObjectContext alloc] init];
                managedObjectContext.persistentStoreCoordinator = coordinator;
                managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
                
                [self.childrenManagedObjectContexts addObject:managedObjectContext];
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(managedObjectContextDidSaveNotification:)
                                                             name:NSManagedObjectContextDidSaveNotification
                                                           object:managedObjectContext];
            }
            
            if (managedObjectContext) {
                threadDictionary[@"managedObjectContext"] = managedObjectContext;
            }
        }
        
        return managedObjectContext;
    }
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:MODEL_NAME withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
#if COREDATA_USE_ORDERED_SET_FIX
    [__managedObjectModel kc_generateOrderedSetAccessors];
#endif
    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    @synchronized(self) {
        /*if (__persistentStoreCoordinator != nil)
        {
            //NSLog(@"ja bebes coordinator");
            return __persistentStoreCoordinator;
        }*/
        
        
#if(USE_LIBRARY_FILE_DOMAIN)
        NSURL *storeURL = [[self applicationPrivateDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", MODEL_NAME]];
#else
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", MODEL_NAME]];
#endif
        
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @YES, NSMigratePersistentStoresAutomaticallyOption,
                                 @YES, NSInferMappingModelAutomaticallyOption, nil];
        
        NSError *error = nil;
        
        
        __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            
        } else {
            
#if(SKIP_BACKUP)
            if(![self addSkipBackupAttributeToItemAtURL:storeURL]){
                abort();
            }
#endif
        }
        
        return __persistentStoreCoordinator;
    }
}

- (void)managedObjectContextDidSaveNotification:(NSNotification *)notification {
    NSManagedObjectContext *senderManagedObjectContext = [self managedObjectContext];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
        
        for (NSManagedObjectContext *childManagedObjectContext in self.childrenManagedObjectContexts) {
            if (childManagedObjectContext != senderManagedObjectContext) {
                [childManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
            }
        }
    });
}

- (void)mainManagedObjectContextDidSaveNotification:(NSNotification *)notification {
    for (NSManagedObjectContext *childManagedObjectContext in self.childrenManagedObjectContexts) {
        [childManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    }
}


// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationPrivateDirectory {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [libraryPath stringByAppendingPathComponent:@"InternalData"];
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            abort(); // replace with proper error handling
        }
    }
    else if (!isDirectory) {
        abort(); // replace with error handling
    }
    return [NSURL fileURLWithPath:path];
}


- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
    if(!success){
        //NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end
