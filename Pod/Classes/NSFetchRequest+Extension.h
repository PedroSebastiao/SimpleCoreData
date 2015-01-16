//
//  NSFetchRequest+Extension.h
//  
//
//  Created by Pedro Sebastião on 16/12/13.
//

#import <CoreData/CoreData.h>

@interface NSFetchRequest (Extension)

- (NSUInteger)count;
- (NSArray *)executeWithError:(NSError **)error;

@end
