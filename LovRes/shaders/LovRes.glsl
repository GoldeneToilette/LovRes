varying vec4 vertexColor;
varying vec3 vertexNormal;
varying vec2 vertexUV;

// placeholder shader if there is no material
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 flippedUV = vec2(vertexUV.x, 1.0 - vertexUV.y);
    vec4 textureColor = Texel(texture, flippedUV);

    vec3 normal = normalize(vertexNormal);
    vec3 lightDirection = normalize(vec3(0.0, 1.0, 1.0));
    float lightIntensity = max(dot(normal, lightDirection), 0.0);

    vec4 litColor = textureColor * lightIntensity;
    return litColor;
}