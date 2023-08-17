shader_type canvas_item;
uniform sampler2D light_vector;
uniform float width = 0.08;
uniform vec4 flowlight = vec4(0.3,0.3,0.0,0.3);//定义一个uniform变量

void fragment(){
	vec4 color = texture(TEXTURE,UV);
		if(color.a != 0.0){
			float v = texture(light_vector,UV).r;
			float diff = v - cos(TIME*0.5);
			if(abs(diff) < width){
			color = color + mix(flowlight,vec4(0.0),abs(diff)/width);//使用flowlight
		}
	}
	COLOR = color;
}
