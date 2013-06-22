//
//  Trip.h
//  CycleTracks
//
//  Created by Gregory Kip on 6/21/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Coord, User;

@interface Trip : NSManagedObject

@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * uploaded;
@property (nonatomic, retain) NSString * purpose;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSDate * saved;
@property (nonatomic, retain) NSNumber * ease;
@property (nonatomic, retain) NSNumber * safety;
@property (nonatomic, retain) NSNumber * convenience;
@property (nonatomic, retain) NSSet *coords;
@property (nonatomic, retain) User *user;
@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)addCoordsObject:(Coord *)value;
- (void)removeCoordsObject:(Coord *)value;
- (void)addCoords:(NSSet *)values;
- (void)removeCoords:(NSSet *)values;

@end
