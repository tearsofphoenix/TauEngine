/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 On-Core
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


#import "ccMacros.h"
#import "CCGrid.h"
#import "CCTexture2D.h"
#import "CCGrabber.h"
#import "CCGLProgram.h"
#import "CCShaderCache.h"
#import "ccGLStateCache.h"
#import "CCNode.h"
#import "CCCamera.h"
#import "CCGLView.h"

#import "Platforms/CCGL.h"
#import "Support/CGPointExtension.h"
#import "Support/ccUtils.h"
#import "Support/TransformUtils.h"
#import "Support/OpenGL_Internal.h"




#ifdef __CC_PLATFORM_IOS
#import "Platforms/iOS/CCDirectorIOS.h"
#import <OpenGLES/EAGLDrawable.h>

#endif // __CC_PLATFORM_IOS


#pragma mark -
#pragma mark CCGridBase

@implementation CCGridBase

@synthesize reuseCount = reuseGrid_;
@synthesize texture = texture_;
@synthesize grabber = grabber_;
@synthesize gridSize = gridSize_;
@synthesize step = step_;
@synthesize shaderProgram = _shaderProgram;

-(id) initWithSize:(ccGridSize)gridSize texture:(CCTexture2D*)texture flippedTexture:(BOOL)flipped
{
	if( (self=[super init]) )
    {
		active_ = NO;
		reuseGrid_ = 0;
		gridSize_ = gridSize;

		self.texture = texture;
		isTextureFlipped_ = flipped;

		CGSize texSize = [texture_ contentSize];
		step_.x = texSize.width / gridSize_.x;
		step_.y = texSize.height / gridSize_.y;

		grabber_ = [[CCGrabber alloc] init];
		[grabber_ grab:texture_];

		[self setShaderProgram: CCShaderCacheGetProgramByName(kCCShader_PositionTexture)];

		[self calculateVertexPoints];
	}
	return self;
}

-(id)initWithSize:(ccGridSize)gSize
{
	CCDirector *director = [CCDirector sharedDirector];
	CGSize s = [director winSizeInPixels];


	unsigned long POTWide = ccNextPOT(s.width);
	unsigned long POTHigh = ccNextPOT(s.height);

#ifdef __CC_PLATFORM_IOS
	CCGLView *glview = (CCGLView*)[[CCDirector sharedDirector] view];
	NSString *pixelFormat = [glview pixelFormat];

	CCTexture2DPixelFormat format = [pixelFormat isEqualToString: kEAGLColorFormatRGB565] ? kCCTexture2DPixelFormat_RGB565 : kCCTexture2DPixelFormat_RGBA8888;
#elif defined(__CC_PLATFORM_MAC)
	CCTexture2DPixelFormat format = kCCTexture2DPixelFormat_RGBA8888;
#endif

	int bpp = ( format == kCCTexture2DPixelFormat_RGB565 ? 2 : 4 );

	void *data = calloc((size_t)(POTWide * POTHigh * bpp), 1);
	if( ! data ) {
		CCLOG(@"cocos2d: CCGrid: not enough memory");
		[self release];
		return nil;
	}

	CCTexture2D *texture = [[CCTexture2D alloc] initWithData:data pixelFormat:format pixelsWide:POTWide pixelsHigh:POTHigh contentSize:s];
	free( data );

	if( ! texture ) {
		CCLOG(@"cocos2d: CCGrid: error creating texture");
		[self release];
		return nil;
	}

	self = [self initWithSize:gSize texture:texture flippedTexture:NO];

	[texture release];

	return self;
}
- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Dimensions = %ldx%ld>", [self class], self, (long)gridSize_.x, (long)gridSize_.y];
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);

//	[self setActive: NO];

	[texture_ release];
	[grabber_ release];
	[super dealloc];
}

// properties
-(BOOL) active
{
	return active_;
}

-(void) setActive:(BOOL)active
{
	active_ = active;
	if( ! active ) {
		CCDirector *director = [CCDirector sharedDirector];
		ccDirectorProjection proj = [director projection];
		[director setProjection:proj];
	}
}

-(BOOL) isTextureFlipped
{
	return isTextureFlipped_;
}

-(void) setIsTextureFlipped:(BOOL)flipped
{
	if( isTextureFlipped_ != flipped ) {
		isTextureFlipped_ = flipped;
		[self calculateVertexPoints];
	}
}

-(void)set2DProjection
{	
	CCDirector *director = [CCDirector sharedDirector];

	CGSize	size = [director winSizeInPixels];
	
	glViewport(0, 0, size.width * CC_CONTENT_SCALE_FACTOR(), size.height * CC_CONTENT_SCALE_FACTOR() );
	VEGLMatrixMode(GL_PROJECTION_MATRIX);
	VEGLLoadIdentity();
	
	GLKMatrix4 orthoMatrix = GLKMatrix4MakeOrtho(0, size.width * CC_CONTENT_SCALE_FACTOR(), 0,
                                                 size.height * CC_CONTENT_SCALE_FACTOR(), -1, 1);
	VECurrentGLMatrixStackMultiplyMatrix4( orthoMatrix );
	
	VEGLMatrixMode(GL_MODELVIEW_MATRIX);
	VEGLLoadIdentity();

	
	CCSetProjectionMatrixDirty();
}

-(void)beforeDraw
{
	// save projection
	CCDirector *director = [CCDirector sharedDirector];
	directorProjection_ = [director projection];
	
	[self set2DProjection];
	
	[grabber_ beforeRender:texture_];
}


-(void)afterDraw:(CCNode *)target
{
	[grabber_ afterRender:texture_];

	// restore projection
	CCDirector *director = [CCDirector sharedDirector];
	[director setProjection: directorProjection_];

	if( target.camera.dirty )
    {

		CGPoint offset = [target anchorPointInPoints];

		//
		// XXX: Camera should be applied in the AnchorPoint
		//
		VEGLTranslatef(offset.x, offset.y, 0);
		[target.camera locate];
		VEGLTranslatef(-offset.x, -offset.y, 0);
	}

	ccGLBindTexture2D( texture_.name );

	[self blit];
}


-(void)blit
{
	[NSException raise:@"GridBase" format:@"Abstract class needs implementation"];
}

-(void)reuse
{
	[NSException raise:@"GridBase" format:@"Abstract class needs implementation"];
}

-(void)calculateVertexPoints
{
	[NSException raise:@"GridBase" format:@"Abstract class needs implementation"];
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark CCGrid3D
@implementation CCGrid3D

-(void)dealloc
{
	free(texCoordinates);
	free(vertices);
	free(indices);
	free(originalVertices);
	[super dealloc];
}

-(void)blit
{
	NSInteger n = gridSize_.x * gridSize_.y;

	VEGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords );
    CCGLProgramUse(_shaderProgram);
    CCGLProgramUniformForModelViewProjectionMatrix(_shaderProgram);

	//
	// Attributes
	//

	// position
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, 0, vertices);

	// texCoods
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, texCoordinates);

	glDrawElements(GL_TRIANGLES, (GLsizei) n*6, GL_UNSIGNED_SHORT, indices);
	
	CC_INCREMENT_GL_DRAWS(1);
}

-(void)calculateVertexPoints
{
	float width = (float)texture_.pixelsWide;
	float height = (float)texture_.pixelsHigh;
	float imageH = texture_.contentSizeInPixels.height;

	int x, y, i;

	if (vertices) free(vertices);
	if (originalVertices) free(originalVertices);
	if (texCoordinates) free(texCoordinates);
	if (indices) free(indices);
	
	NSUInteger numOfPoints = (gridSize_.x+1) * (gridSize_.y+1);
	
	vertices = malloc(numOfPoints * sizeof(GLKVector3));
	originalVertices = malloc(numOfPoints * sizeof(GLKVector3));
	texCoordinates = malloc(numOfPoints * sizeof(GLKVector2));
	indices = malloc( (gridSize_.x * gridSize_.y) * sizeof(GLushort)*6);

	GLfloat *vertArray = (GLfloat*)vertices;
	GLfloat *texArray = (GLfloat*)texCoordinates;
	GLushort *idxArray = (GLushort *)indices;

	for( x = 0; x < gridSize_.x; x++ )
	{
		for( y = 0; y < gridSize_.y; y++ )
		{
			NSInteger idx = (y * gridSize_.x) + x;

			GLfloat x1 = x * step_.x;
			GLfloat x2 = x1 + step_.x;
			GLfloat y1 = y * step_.y;
			GLfloat y2 = y1 + step_.y;

			GLushort a = x * (gridSize_.y+1) + y;
			GLushort b = (x+1) * (gridSize_.y+1) + y;
			GLushort c = (x+1) * (gridSize_.y+1) + (y+1);
			GLushort d = x * (gridSize_.y+1) + (y+1);

			GLushort	tempidx[6] = { a, b, d, b, c, d };

			memcpy(&idxArray[6*idx], tempidx, 6*sizeof(GLushort));

			int l1[4] = { a*3, b*3, c*3, d*3 };
			GLKVector3	e = GLKVector3Make(x1,y1,0);
			GLKVector3	f = GLKVector3Make(x2,y1,0);
			GLKVector3	g = GLKVector3Make(x2,y2,0);
			GLKVector3	h = GLKVector3Make(x1,y2,0);

			GLKVector3 l2[4] = { e, f, g, h };

			int tex1[4] = { a*2, b*2, c*2, d*2 };
			CGPoint tex2[4] = { ccp(x1, y1), ccp(x2, y1), ccp(x2, y2), ccp(x1, y2) };

			for( i = 0; i < 4; i++ )
			{
				vertArray[ l1[i] ] = l2[i].x;
				vertArray[ l1[i] + 1 ] = l2[i].y;
				vertArray[ l1[i] + 2 ] = l2[i].z;

				texArray[ tex1[i] ] = tex2[i].x / width;
				if( isTextureFlipped_ )
					texArray[ tex1[i] + 1 ] = (imageH - tex2[i].y) / height;
				else
					texArray[ tex1[i] + 1 ] = tex2[i].y / height;
			}
		}
	}

	memcpy(originalVertices, vertices, (gridSize_.x+1)*(gridSize_.y+1)*sizeof(GLKVector3));
}

-(GLKVector3)vertex:(ccGridSize)pos
{
	NSInteger index = (pos.x * (gridSize_.y+1) + pos.y) * 3;
	float *vertArray = (float *)vertices;

	GLKVector3	vert = GLKVector3Make( vertArray[index], vertArray[index+1], vertArray[index+2] );

	return vert;
}

-(GLKVector3)originalVertex:(ccGridSize)pos
{
	NSInteger index = (pos.x * (gridSize_.y+1) + pos.y) * 3;
	float *vertArray = (float *)originalVertices;

	GLKVector3	vert = GLKVector3Make( vertArray[index], vertArray[index+1], vertArray[index+2] );

	return vert;
}

-(void)setVertex:(ccGridSize)pos vertex:(GLKVector3)vertex
{
	NSInteger index = (pos.x * (gridSize_.y+1) + pos.y) * 3;
	float *vertArray = (float *)vertices;
	vertArray[index] = vertex.x;
	vertArray[index+1] = vertex.y;
	vertArray[index+2] = vertex.z;
}

-(void)reuse
{
	if ( reuseGrid_ > 0 )
	{
		memcpy(originalVertices, vertices, (gridSize_.x+1)*(gridSize_.y+1)*sizeof(GLKVector3));
		reuseGrid_--;
	}
}

@end

////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark CCTiledGrid3D

@implementation CCTiledGrid3D

-(void)dealloc
{
	free(texCoordinates);
	free(vertices);
	free(indices);
	free(originalVertices);
	[super dealloc];
}

-(void)blit
{
	NSInteger n = gridSize_.x * gridSize_.y;

    CCGLProgramUse(_shaderProgram);
    CCGLProgramUniformForModelViewProjectionMatrix(_shaderProgram);


	//
	// Attributes
	//
	VEGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords );

	// position
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, 0, vertices);

	// texCoods
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, texCoordinates);

	glDrawElements(GL_TRIANGLES, (GLsizei) n*6, GL_UNSIGNED_SHORT, indices);
	
	CC_INCREMENT_GL_DRAWS(1);
}

-(void)calculateVertexPoints
{
	float width = (float)texture_.pixelsWide;
	float height = (float)texture_.pixelsHigh;
	float imageH = texture_.contentSizeInPixels.height;

	NSInteger numQuads = gridSize_.x * gridSize_.y;

	if (vertices) free(vertices);
	if (originalVertices) free(originalVertices);
	if (texCoordinates) free(texCoordinates);
	if (indices) free(indices);

	vertices = malloc(numQuads*4*sizeof(GLKVector3));
	originalVertices = malloc(numQuads*4*sizeof(GLKVector3));
	texCoordinates = malloc(numQuads*4*sizeof(GLKVector2));
	indices = malloc(numQuads*6*sizeof(GLushort));

	GLfloat *vertArray = (GLfloat*)vertices;
	GLfloat *texArray = (GLfloat*)texCoordinates;
	GLushort *idxArray = (GLushort *)indices;

	int x, y;

	for( x = 0; x < gridSize_.x; x++ )
	{
		for( y = 0; y < gridSize_.y; y++ )
		{
			float x1 = x * step_.x;
			float x2 = x1 + step_.x;
			float y1 = y * step_.y;
			float y2 = y1 + step_.y;

			*vertArray++ = x1;
			*vertArray++ = y1;
			*vertArray++ = 0;
			*vertArray++ = x2;
			*vertArray++ = y1;
			*vertArray++ = 0;
			*vertArray++ = x1;
			*vertArray++ = y2;
			*vertArray++ = 0;
			*vertArray++ = x2;
			*vertArray++ = y2;
			*vertArray++ = 0;

			float newY1 = y1;
			float newY2 = y2;

			if( isTextureFlipped_ ) {
				newY1 = imageH - y1;
				newY2 = imageH - y2;
			}

			*texArray++ = x1 / width;
			*texArray++ = newY1 / height;
			*texArray++ = x2 / width;
			*texArray++ = newY1 / height;
			*texArray++ = x1 / width;
			*texArray++ = newY2 / height;
			*texArray++ = x2 / width;
			*texArray++ = newY2 / height;
		}
	}

	for( x = 0; x < numQuads; x++)
	{
		idxArray[x*6+0] = x*4+0;
		idxArray[x*6+1] = x*4+1;
		idxArray[x*6+2] = x*4+2;

		idxArray[x*6+3] = x*4+1;
		idxArray[x*6+4] = x*4+2;
		idxArray[x*6+5] = x*4+3;
	}

	memcpy(originalVertices, vertices, numQuads*12*sizeof(GLfloat));
}

-(void)setTile:(ccGridSize)pos coords:(ccQuad3)coords
{
	NSInteger idx = (gridSize_.y * pos.x + pos.y) * 4 * 3;
	float *vertArray = (float*)vertices;
	memcpy(&vertArray[idx], &coords, sizeof(ccQuad3));
}

-(ccQuad3)originalTile:(ccGridSize)pos
{
	NSInteger idx = (gridSize_.y * pos.x + pos.y) * 4 * 3;
	float *vertArray = (float*)originalVertices;

	ccQuad3 ret;
	memcpy(&ret, &vertArray[idx], sizeof(ccQuad3));

	return ret;
}

-(ccQuad3)tile:(ccGridSize)pos
{
	NSInteger idx = (gridSize_.y * pos.x + pos.y) * 4 * 3;
	float *vertArray = (float*)vertices;

	ccQuad3 ret;
	memcpy(&ret, &vertArray[idx], sizeof(ccQuad3));

	return ret;
}

-(void)reuse
{
	if ( reuseGrid_ > 0 )
	{
		NSInteger numQuads = gridSize_.x * gridSize_.y;

		memcpy(originalVertices, vertices, numQuads*12*sizeof(GLfloat));
		reuseGrid_--;
	}
}

@end
