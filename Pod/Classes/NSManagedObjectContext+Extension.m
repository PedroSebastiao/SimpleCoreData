//
//  NSManagedObjectContext+Extension.m
//
//
//  Created by Pedro Sebastião on 16/12/13.
//

#import "NSManagedObjectContext+Extension.h"
#import "PSCoreDataStackManager.h"

@implementation NSManagedObjectContext (Extension)

+ (BOOL)save {
    return [self save:nil];
}

+ (BOOL)save:(NSError **)errorOut
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [PSCoreDataStackManager sharedManager].managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    if (errorOut) {
        *errorOut = error;
    }
    return YES;
}

@end
