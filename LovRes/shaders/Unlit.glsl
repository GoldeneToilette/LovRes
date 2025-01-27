uniform vec4 u_color;
uniform sampler2D u_texture;
uniform bool u_useTexture;

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