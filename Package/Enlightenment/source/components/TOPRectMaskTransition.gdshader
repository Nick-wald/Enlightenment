shader_type canvas_item;

uniform float cutoff: hint_range(0.0, 1.0) = 0.5;//截断区域
uniform float tran: hint_range(0.0, 1.0) = 0.1;//过渡区域
uniform vec4 col = vec4(0, 0, 0, 1);//遮罩颜色
void fragment() {
	vec4 Maskcol = col;
	Maskcol.a = smoothstep(cutoff - tran, cutoff, UV.x * (1.0 - tran));
	COLOR = Maskcol;
}
