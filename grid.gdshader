shader_type canvas_item;

uniform vec2 grid_size = vec2(10, 10);
uniform vec4 alive_color = vec4(1.0);
uniform vec4 dead_color = vec4(0.0);

uniform sampler2D cells : source_color, filter_nearest;

//vec2 grid(vec2 uv, float columns, float rows){
	//return fract(vec2(uv.x * columns, uv.y * rows));
//}

vec4 square_rounded(vec2 uv, float width, float radius){
	uv = uv * 2.0 - 1.0;
	
	radius *= width; // make radius go from 0-1 instead of 0-width
	vec2 abs_uv = abs(uv.xy) - radius;
	vec2 dist = vec2(max(abs_uv.xy, 0.0));
	float square = step(width - radius, length(dist));
	return vec4(vec3(square), 1.0);
}


void fragment() {
	vec2 grid = fract(UV * grid_size);
	float cell = texture(cells, vec2(UV)).r;
	
	float m = 1.0 - square_rounded(grid, 1, 0.4).x;
	
	vec4 c = mix(dead_color, alive_color, cell * m);
	
    COLOR = c;
}
