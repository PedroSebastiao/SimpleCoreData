//
//  NSManagedObjectContext+Extension.h
//  
//
//  Created by Pedro Sebastião on 16/12/13.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Extension)

+ (BOOL)save;
+ (BOOL)save:(NSError **)error;

@end
