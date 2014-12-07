varying vec3 color;
varying float alpha;
varying vec3 normal;
varying vec3 light;
void main() {
	vec3 n = normalize(normal);
	float diffuse = max(0.0, dot(light, n));
	float specular = pow(max(0.0, -reflect(light, n).z), 10.0) * sqrt(diffuse);
	gl_FragColor = vec4(mix(color * (0.3 + 0.7 * diffuse), vec3(1.0), specular), alpha);
}