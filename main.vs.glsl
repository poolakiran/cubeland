#version 120

uniform mat4 view;
uniform mat4 projection;
uniform vec3 camera_position;

attribute vec3 position;
attribute vec3 normal;
attribute float blocktype;

varying vec4 frag_diffuse_factor;
varying vec2 frag_texcoord1;
varying vec2 frag_texcoord2;
varying float frag_tex_factor;
varying float frag_fog_factor;

const vec3 light_direction = vec3(0.408248, -0.816497, 0.408248);
const vec4 light_diffuse = vec4(0.8, 0.8, 0.8, 0.0);
const vec4 light_ambient = vec4(0.2, 0.2, 0.2, 1.0);

const float planet_radius = 6371000.0 / 5000.0;
const float fog_density = 0.003;
const float tex_size = 128.0;

const float BLOCK_GRASS = 1.0;
const float BLOCK_STONE = 2.0;
const float BLOCK_DIRT = 3.0;
const float BLOCK_WATER = 4.0;

void main() {
    float horiz_dist = length(camera_position - position);

    /* Curvature of the planet */
    vec3 curved_position = position;
    //curved_position.y -= planet_radius - sqrt(pow(planet_radius, 2.0) - pow(horiz_dist, 2.0));

    vec4 eye_position = view * vec4(curved_position, 1.0);

    gl_Position = projection * eye_position;

    if (normal.x != 0.0) {
        frag_texcoord1 = position.yz;
    } else if (normal.y != 0.0) {
        frag_texcoord1 = position.xz;
    } else {
        frag_texcoord1 = position.xy;
    }

    frag_texcoord1 /= tex_size;
    frag_texcoord2 = frag_texcoord1;

    vec4 base_color;
    if (blocktype == BLOCK_GRASS) {
        base_color = vec4(0.0, 0.8, 0.2, 1.0);
        frag_texcoord1 *= 0.5;
        frag_texcoord2 *= 16.0;
        frag_tex_factor = 0.8;
    } else if (blocktype == BLOCK_STONE) {
        base_color = vec4(0.8, 0.8, 0.8, 1.0);
        frag_texcoord1 *= 1.0;
        frag_texcoord2 *= 8.0;
        frag_tex_factor = 0.3;
    } else if (blocktype == BLOCK_DIRT) {
        base_color = vec4(0.63, 0.35, 0.03, 1.0);
        frag_texcoord1 *= 0.5;
        frag_texcoord2 *= 16.0;
        frag_tex_factor = 0.8;
    } else if (blocktype == BLOCK_WATER) {
        base_color = vec4(0.1, 0.1, 0.9, 1.0);
        frag_texcoord1 *= 2.0;
        frag_texcoord2 *= 0.1;
        frag_tex_factor = 0.8;
    } else {
        base_color = vec4(1.0, 0.0, 0.0, 1.0);
        frag_texcoord1 *= 16.0;
        frag_texcoord2 *= 16.0;
        frag_tex_factor = 0.5;
    }

    vec4 diffuse_factor
        = max(-dot(normal, light_direction), 0.0) * light_diffuse;
    frag_diffuse_factor = (diffuse_factor + light_ambient) * base_color;

    frag_fog_factor = clamp(exp2(-pow(length(eye_position), 2.0) * pow(fog_density, 2.0) * 1.44), 0.0, 1.0);
}
