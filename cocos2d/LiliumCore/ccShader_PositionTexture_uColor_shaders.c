#include <OpenGLES/ES2/gl.h>

const GLchar * ccPositionTexture_uColor_frag = "										\n\
#ifdef GL_ES							\n\
precision lowp float;					\n\
#endif									\n\
\n\
uniform		vec4 u_color;				\n\
\n\
varying vec2 v_texCoord;				\n\
\n\
uniform sampler2D u_texture;			\n\
\n\
void main()								\n\
{										\n\
gl_FragColor =  texture2D(u_texture, v_texCoord) * u_color;	\n\
}										\n\
";

const GLchar * ccPositionTexture_uColor_vert = "									\n\
attribute vec4 a_position;			\n\
attribute vec2 a_texCoord;			\n\
									\n\
uniform	mat4 u_MVPMatrix;			\n\
									\n\
#ifdef GL_ES						\n\
varying mediump vec2 v_texCoord;	\n\
#else								\n\
varying vec2 v_texCoord;			\n\
#endif								\n\
									\n\
void main()							\n\
{									\n\
    gl_Position = u_MVPMatrix * a_position;		\n\
	v_texCoord = a_texCoord;		\n\
}									\n\
";
