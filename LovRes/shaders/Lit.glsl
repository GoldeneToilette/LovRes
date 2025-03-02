struct DirectionalLight {
    vec3 direction;
    vec3 color;
    float intensity;
};

struct PointLight {
    vec3 position;
    vec3 color;
    float intensity;
    vec3 attenuation;
};

struct SpotLight {
    vec3 position;
    vec3 direction;
    float angle;
    vec3 color;
    float intensity;
    vec3 attenuation;
};

uniform DirectionalLight lights[10];
uniform PointLight lights[10];
uniform SpotLight lights[10];

uniform vec4 u_color;
uniform sampler2D u_texture;
uniform bool u_useTexture;
uniform sampler2D normalMap;

varying vec3 vertexNormal;
varying vec2 vertexUV;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    if(u_useTexture) {
        vec2 flippedUV = vec2(vertexUV.x, 1.0 - vertexUV.y);
        vec4 textureColor = texture2D(u_texture, flippedUV);
        return textureColor;
    } else {
        return u_color;
    }
}