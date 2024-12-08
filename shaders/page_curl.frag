#include<flutter/runtime_effect.glsl>

uniform highp vec2 resolution;
uniform highp float pointer;
uniform highp vec4 container;
uniform highp float cornerRadius;
uniform highp float scrollDirection;
uniform highp sampler2D image;

const highp float r = 0.25; // 25% of the container width
const highp float scaleFactor = 0.2;

#define PI 3.14159265359
#define TRANSPARENT vec4(0., 0., 0., 0.)
#define RED vec4(1., 0., 0., 1.)

highp mat3 translate(highp vec2 p) {
return mat3(1., 0., 0., 0., 1., 0., p.x, p.y, 1.);
}

highp mat3 scale(highp vec2 s, highp vec2 p) {
return translate(p) * mat3(s.x, 0., 0., 0., s.y, 0., 0., 0., 1.) * translate(-p);
}

// Combine inverse logic directly into the project function
highp vec2 project(highp vec2 p, highp mat3 m) {
highp float a00 = m[0][0], a01 = m[0][1], a02 = m[0][2];
highp float a10 = m[1][0], a11 = m[1][1], a12 = m[1][2];
highp float a20 = m[2][0], a21 = m[2][1], a22 = m[2][2];

highp float b01 = a22 * a11 - a12 * a21;
highp float b11 = -a22 * a10 + a12 * a20;
highp float b21 = a21 * a10 - a11 * a20;

highp float det = a00 * b01 + a01 * b11 + a02 * b21;

// Avoid division by zero
if (det == 0.0) {
return p;
}

highp float invDet = 1.0 / det;

highp mat3 invMat = mat3(
        b01 * invDet,
        (-a22 * a01 + a02 * a21) * invDet,
        (a12 * a01 - a02 * a11) * invDet,
        b11 * invDet,
        (a22 * a00 - a02 * a20) * invDet,
        (-a12 * a00 + a02 * a10) * invDet,
        b21 * invDet,
        (-a21 * a00 + a01 * a20) * invDet,
        (a11 * a00 - a01 * a10) * invDet
);

return (invMat * vec3(p, 1.)).xy;
}

bool inRect(highp vec2 p, highp vec4 rct) {
bool inRct = p.x > rct.x && p.x < rct.z && p.y > rct.y && p.y < rct.w;
if (!inRct) {
return false;
}
if (p.x < rct.x + cornerRadius && p.y < rct.y + cornerRadius) {
return length(p - vec2(rct.x + cornerRadius, rct.y + cornerRadius)) < cornerRadius;
}
if (p.x > rct.z - cornerRadius && p.y < rct.y + cornerRadius) {
return length(p - vec2(rct.z - cornerRadius, rct.y + cornerRadius)) < cornerRadius;
}
if (p.x < rct.x + cornerRadius && p.y > rct.w - cornerRadius) {
return length(p - vec2(rct.x + cornerRadius, rct.w - cornerRadius)) < cornerRadius;
}
if (p.x > rct.z - cornerRadius && p.y > rct.w - cornerRadius) {
return length(p - vec2(rct.z - cornerRadius, rct.w - cornerRadius)) < cornerRadius;
}
return true;
}

out highp vec4 fragColor;

void main() {
    highp vec2 uv = gl_FragCoord.xy / resolution;
    highp vec2 center = vec2(0.5, 0.5);

    highp float containerWidth = container.z - container.x;
    highp float containerLeft = container.x / resolution.x;
    highp float containerRight = container.z / resolution.x;

    highp float normalizedPointer = pointer * abs(scrollDirection);
    highp float x = (scrollDirection > 0.) ? containerLeft + normalizedPointer : containerRight + normalizedPointer;
    highp float d = (scrollDirection > 0.) ? x - uv.x : uv.x - x;

    highp float normalizedRadius = r * containerWidth / resolution.x;

    if (d > normalizedRadius) {
        fragColor = TRANSPARENT;
    } else if (d > 0.) {
        highp float theta = asin(d / normalizedRadius);
        highp float d1 = theta * normalizedRadius;
        highp float d2 = (PI - theta) * normalizedRadius;
        const highp float HALF_PI = PI / 2.;

        highp vec2 s = vec2(1. + (1. - sin(HALF_PI + theta)) * 0.1);
        highp mat3 transform = scale(s, center);
        highp vec2 curledUV = project(uv, transform);
        highp vec2 p1 = (scrollDirection > 0.) ? vec2(x - d1, curledUV.y) : vec2(x + d1, curledUV.y);

        s = vec2(1.1 + sin(HALF_PI + theta) * 0.1);
        transform = scale(s, center);
        curledUV = project(uv, transform);
        highp vec2 p2 = (scrollDirection > 0.) ? vec2(x - d2, curledUV.y) : vec2(x + d2, curledUV.y);

        if (inRect(p2 * resolution, container)) {
            fragColor = texture(image, p2);
        } else if (inRect(p1 * resolution, container)) {
            fragColor = texture(image, p1);
            fragColor.rgb *= pow(clamp((normalizedRadius - d) / r, 0., 1.), 0.2);
        } else if (inRect(uv * resolution, container)) {
            fragColor = TRANSPARENT;
        }
    } else {
        highp vec2 s = vec2(1.2);
        highp mat3 transform = scale(s, center);
        highp vec2 curledUV = project(uv, transform);

        highp vec2 p = (scrollDirection > 0.) ? vec2(x - abs(d) - PI * normalizedRadius, curledUV.y) : vec2(x + abs(d) + PI * normalizedRadius, curledUV.y);
        if (inRect(p * resolution, container)) {
            fragColor = texture(image, p);
        } else {
            fragColor = texture(image, uv);
        }
    }
}
