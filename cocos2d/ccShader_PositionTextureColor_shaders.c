#include <OpenGLES/ES2/gl.h>

const GLchar * ccPositionTextureColor_frag = "											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
uniform sampler2D u_texture;				\n\
\n\
void main()									\n\
{											\n\
gl_FragColor = v_fragmentColor * texture2D(u_texture, v_texCoord);			\n\
}											\n\
";

const GLchar * ccPositionTextureColor_vert = "													\n\
attribute vec4 a_position;							\n\
attribute vec2 a_texCoord;							\n\
attribute vec4 a_color;								\n\
													\n\
uniform		mat4 u_MVPMatrix;						\n\
													\n\
#ifdef GL_ES										\n\
varying lowp vec4 v_fragmentColor;					\n\
varying mediump vec2 v_texCoord;					\n\
#else												\n\
varying vec4 v_fragmentColor;						\n\
varying vec2 v_texCoord;							\n\
#endif												\n\
													\n\
void main()											\n\
{													\n\
    gl_Position = u_MVPMatrix * a_position;			\n\
	v_fragmentColor = a_color;						\n\
	v_texCoord = a_texCoord;						\n\
}													\n\
";
