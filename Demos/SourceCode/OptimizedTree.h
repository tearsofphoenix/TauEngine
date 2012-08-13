//
//  OptimizedTree.h
//  ExampleEngine
//
//  Created by Ian Terrell on 8/18/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "VEShape.h"
#import "VERectangle.h"
#import "VETriangle.h"

@interface OptimizedShape : VEShape  {
  VEShape *prototype;
}
@end

@interface OptimizedTrunk : OptimizedShape
@end

@interface OptimizedLeaves : OptimizedShape
@end

@interface OptimizedTree : VEShape
@end
