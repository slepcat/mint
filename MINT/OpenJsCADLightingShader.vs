// Input vertex data, different for all executions of this shader.
//attribute vec3 vertexPosition_modelspace;
attribute vec3 vertexColor;
attribute float vertexAlpha;
attribute vec3 vertexNormal;

varying vec3 color;
varying float alpha;
varying vec3 normal;
varying vec3 light;
void main() {
	const vec3 lightDir = vec3(1.0, 2.0, 3.0) / 3.741657386773941;
	light = lightDir;
	color = vertexColor;
	alpha = vertexAlpha;
	normal = gl_NormalMatrix * vertexNormal;
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}