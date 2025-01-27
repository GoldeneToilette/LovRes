uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

attribute vec3 VertexNormal;
attribute vec2 VertexUV;

attribute vec3 InstancePosition;

varying vec4 worldPosition;
varying vec4 viewPosition;
varying vec4 screenPosition;
varying vec3 vertexNormal;
varying vec4 vertexColor;
varying vec2 vertexUV;

// default vertex shader
vec4 position(mat4 transformProjection, vec4 vertexPosition) {
    worldPosition = modelMatrix * vertexPosition;  
    worldPosition.xyz += InstancePosition;
    viewPosition = viewMatrix * worldPosition;   
    screenPosition = projectionMatrix * viewPosition; 

    vertexNormal = VertexNormal;
    vertexUV = VertexUV;
    vertexColor = VertexColor;

    screenPosition.y *= -1.0;
    return screenPosition; 
}