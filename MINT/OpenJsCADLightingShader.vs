varying vec3 color;
varying float alpha;
varying vec3 normal;
varying vec3 light;
void main() {
	const vec3 lightDir = vec3(1.0, 2.0, 3.0) / 3.741657386773941;
	light = lightDir;
	color = gl_Color.rgb;
	alpha = gl_Color.a;
	normal = gl_NormalMatrix * gl_Normal;
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}