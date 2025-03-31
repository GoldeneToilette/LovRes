uniform float desaturationValue;
uniform float bleedStrength;
uniform float aberrationStrength;
uniform float stripeFrequency;

uniform float time;

// returns a random float value
float random(float t) {
    return fract(sin(t * 1234.567) * 43758.5453) * 2.0 - 1.0;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 texColor = Texel(texture, texture_coords);
    float gray = dot(texColor.rgb, vec3(0.3, 0.59, 0.11));

    // desaturate the image ----------------------------------------------------
    vec3 desaturatedColor = mix(texColor.rgb, vec3(gray), desaturationValue);
    // desaturate the image ----------------------------------------------------



    // bleed colors into adjacent pixels ------------------------------------------
    vec2 offset = vec2(1.0 / 512.0, 1.0 / 512.0); // Adjust this for resolution

    // Sample surrounding pixels (expand to 8 neighbors)
    vec4 left = Texel(texture, texture_coords - vec2(offset.x, 0.0)); // left
    vec4 right = Texel(texture, texture_coords + vec2(offset.x, 0.0)); // right
    vec4 top = Texel(texture, texture_coords + vec2(0.0, offset.y)); // up
    vec4 bottom = Texel(texture, texture_coords - vec2(0.0, offset.y)); // down
    vec4 topLeft = Texel(texture, texture_coords + vec2(-offset.x, offset.y)); // top-left
    vec4 topRight = Texel(texture, texture_coords + vec2(offset.x, offset.y)); // top-right
    vec4 bottomLeft = Texel(texture, texture_coords - vec2(offset.x, offset.y)); // bottom-left
    vec4 bottomRight = Texel(texture, texture_coords + vec2(offset.x, -offset.y)); // bottom-right

    // Average the color of these 8 surrounding pixels
    vec3 averagedColor = (left.rgb + right.rgb + top.rgb + bottom.rgb +
                        topLeft.rgb + topRight.rgb + bottomLeft.rgb + bottomRight.rgb) / 8.0;

    // Blend the averaged color with the desaturated color based on the bleed strength
    vec3 secondPass = mix(desaturatedColor, averagedColor, bleedStrength);
    // bleed colors into adjacent pixels ------------------------------------------



    // chromatic aberration ------------------------------------------------------
    float shiftAmountR = aberrationStrength * 0.01;
    float shiftAmountG = aberrationStrength * 0.005;
    float shiftAmountB = aberrationStrength * 0.02;

    vec2 uvR = texture_coords + vec2(shiftAmountR, 0.0);
    vec2 uvG = texture_coords + vec2(shiftAmountG, 0.0);
    vec2 uvB = texture_coords + vec2(shiftAmountB, 0.0);

    vec4 texColorR = Texel(texture, uvR);  // Red channel
    vec4 texColorG = Texel(texture, uvG);  // Green channel
    vec4 texColorB = Texel(texture, uvB);  // Blue channel

    vec3 aberrationPixel = vec3(texColorR.r, texColorG.g, texColorB.b);  
    vec3 thirdPass = mix(aberrationPixel, secondPass, 0.7);
    // chromatic aberration ------------------------------------------------------  



    // brightness flicker --------------------------------------------------------
    float flickerNoise = fract(sin(dot(texture_coords.xy + time * 0.1, vec2(12.9898, 78.233))) * 43758.5453);
    flickerNoise = abs(flickerNoise * 2.0 - 1.0);

    float brightnessFactor = mix(0.5, 1.5, flickerNoise); 

    vec3 fourthPass = thirdPass * brightnessFactor;
    // brightness flicker --------------------------------------------------------



    // random white stripes ----------------------------------------------------------
    vec3 fifthPass = vec3(0.0, 0.0, 0.0);

    float randomPos = fract(random(time + screen_coords.y) * 0.5 + 0.5);

    float stripePattern = sin(randomPos * 6.2832 + time * 0.2);

    float stripeChance = 0.00005 * stripeFrequency;
    if (abs(stripePattern) < stripeChance) { 
        float intensity = mix(0.2, 0.8, random(time * screen_coords.y));

        fifthPass = vec3(fourthPass + intensity);
    } else {
        fifthPass = fourthPass;
    }
    // random white stripes ----------------------------------------------------------

    return vec4(fifthPass, texColor.a);
}