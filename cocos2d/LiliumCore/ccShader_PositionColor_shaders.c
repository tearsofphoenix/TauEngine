#include <OpenGLES/ES2/gl.h>

const GLchar * ccPositionColor_frag = "				\n\
#ifdef GL_ES										\n\
precision lowp float;								\n\
#endif												\n\
                                                    \n\
varying vec4 v_fragmentColor;						\n\
                                                    \n\
void main()											\n\
{													\n\
    gl_FragColor = v_fragmentColor;					\n\
}													\n\
";


const GLchar * ccPositionColor_vert = "					\n\
attribute vec4 a_position;								\n\
attribute vec4 a_color;									\n\
uniform	mat4 u_MVPMatrix;								\n\
														\n\
#ifdef GL_ES											\n\
varying lowp vec4 v_fragmentColor;						\n\
#else													\n\
varying vec4 v_fragmentColor;							\n\
#endif													\n\
														\n\
void main()												\n\
{														\n\
    gl_Position = u_MVPMatrix * a_position;				\n\
	v_fragmentColor = a_color;							\n\
}														\n\
";
