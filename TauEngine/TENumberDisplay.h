//
//  TENumberDisplay.h
//  TauGame
//
//  Created by Ian Terrell on 7/28/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TEPolygon.h"

@interface TENumberDisplay : TEPolygon
{
    int _padDigit;
}

@property (nonatomic) int number;
@property (nonatomic) int numDigits;
@property (nonatomic) int hiddenDigits;
@property (nonatomic) int decimalPointDigit;

@property (nonatomic, readonly) float height;

@property (nonatomic) float width;

- (id)initWithNumDigits: (int)num;

@end
