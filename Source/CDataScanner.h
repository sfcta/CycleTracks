/**  CycleTracks, Copyright 2009-2013 San Francisco County Transportation Authority
 *                                    San Francisco, CA, USA
 *
 *   @author Matt Paul <mattpaul@mopimp.com>
 *
 *   This file is part of CycleTracks.
 *
 *   CycleTracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   CycleTracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  CDataScanner.h
//  TouchJSON
//
//  Created by Jonathan Wight on 04/16/08.
//  Copyright 2008 Toxic Software. All rights reserved.
//

#import <Foundation/Foundation.h>

// NSScanner

@interface CDataScanner : NSObject {
	NSData *data;

	u_int8_t *start;
	u_int8_t *end;
	u_int8_t *current;
	NSUInteger length;
	
	NSCharacterSet *doubleCharacters;
}

@property (readwrite, nonatomic, strong) NSData *data;
@property (readwrite, nonatomic, assign) NSUInteger scanLocation;
@property (readonly, nonatomic, assign) BOOL isAtEnd;

+ (id)scannerWithData:(NSData *)inData;

- (unichar)currentCharacter;
- (unichar)scanCharacter;
- (BOOL)scanCharacter:(unichar)inCharacter;

- (BOOL)scanUTF8String:(const char *)inString intoString:(NSString **)outValue;
- (BOOL)scanString:(NSString *)inString intoString:(NSString **)outValue;
- (BOOL)scanCharactersFromSet:(NSCharacterSet *)inSet intoString:(NSString **)outValue; // inSet must only contain 7-bit ASCII characters

- (BOOL)scanUpToString:(NSString *)string intoString:(NSString **)outValue;
- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet *)set intoString:(NSString **)outValue; // inSet must only contain 7-bit ASCII characters

- (BOOL)scanNumber:(NSNumber **)outValue;

- (void)skipWhitespace;

- (NSString *)remainingString;

@end
