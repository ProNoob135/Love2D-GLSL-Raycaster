vec4 HSLtoRGB(in vec4 HSLA){
    vec3 RGB;
	if(HSLA.y<=0){
        return vec4(HSLA.z, HSLA.z, HSLA.z, HSLA.w);
    }
	HSLA.x = HSLA.x*6;
	float c = (1-abs(2*HSLA.z-1))*HSLA.y;
	float x = (1-abs(mod(HSLA.x, 2)-1 ) )*c;
	float m = (HSLA.z-0.5*c);
	if(HSLA.x < 1)     {RGB = vec3(c, x, 0);}
	else if(HSLA.x < 2){RGB = vec3(x, c, 0);}
	else if(HSLA.x < 3){RGB = vec3(0, c, x);}
	else if(HSLA.x < 4){RGB = vec3(0, x, c);}
	else if(HSLA.x < 5){RGB = vec3(x, 0, c);}
	else               {RGB = vec3(c, 0, x);}
	return vec4( (RGB.x+m), (RGB.y+m), (RGB.z+m), HSLA.w);
}

float pythag(in vec3 pos1, in vec3 pos2){
    vec3 manhattanDist = abs(pos2 - pos1);
    return (sqrt(pow(manhattanDist.x, 2) + pow(manhattanDist.y, 2) + pow(manhattanDist.z, 2) ) );
}

float manhattan(in vec3 pos1, in vec3 pos2){
    vec3 manhattanDist = abs(pos2 - pos1);
    return manhattanDist.x + manhattanDist.y + manhattanDist.z;
}

float triangle(in float n1, in float n2){
    return abs(mod(n1 - n2, 2.0*n2) - n2);
}

float lerp(in float x1, in float x2, in float n){
    return n*(x2 - x1) + x1;
}

vec4 lerp(in vec4 x1, in vec4 x2, in float n){
    return n*(x2 - x1) + x1;
}

float bounds(in float x, in float n1, in float n2){
    if(n1 > n2){
        return min(n1, max(n2, x) );
    }
    else{
        return min(n2, max(n1, x) );
    }
}

uniform vec2 dimensions;
uniform vec2 rot;
uniform float fov;
uniform vec3 pos;
uniform float rendDist;
uniform float lod;
uniform sampler2D testTexture;
uniform sampler2D heightmap;

uniform float waterHeight;

float pi = 3.1415926535897932384626433832795;
vec4 pixel = vec4(0.24, 0.712, 0.865, 1.0);

vec3 rayPos = vec3(0.0, 0.0, 0.0);

vec4 effect( vec4 color, sampler2D texture, vec2 texture_coords, vec2 screen_coords ){

    vec2 fragRot = vec2(
        fov*(screen_coords.x/dimensions.x) - fov/2.0,
        fov*( (screen_coords.y + (dimensions.x - dimensions.y)/2)/dimensions.x) - fov/2.0 - pi/2.0);

    mat2x2 rotPreCalc;
    mat2x2 fragRotPreCalc;

    for(int i = 0; i <= 1; i++){
        rotPreCalc[i] = vec2(cos(rot[i]), sin(rot[i]) );
        fragRotPreCalc[i] = vec2(cos(fragRot[i]), sin(fragRot[i]) );
    }

    float dist;

    for(dist = 1.0; dist <= rendDist; dist = dist + (dist-0.5)/lod){

        rayPos.xy = vec2(
            dist*fragRotPreCalc[0].x,
            dist*fragRotPreCalc[0].y);

        rayPos.xz = vec2(
            rayPos.x*fragRotPreCalc[1].x,
            -rayPos.x*fragRotPreCalc[1].y);

        rayPos.xz = vec2(
            rayPos.x*rotPreCalc[1].x + rayPos.z*rotPreCalc[1].y,
            rayPos.z*rotPreCalc[1].x - rayPos.x*rotPreCalc[1].y );

        rayPos.xy = vec2(
            rayPos.x*rotPreCalc[0].x - rayPos.y*rotPreCalc[0].y,
            rayPos.y*rotPreCalc[0].x + rayPos.x*rotPreCalc[0].y );

        rayPos = rayPos + pos - vec3(rotPreCalc[0].x, rotPreCalc[0].y, rotPreCalc[1].x );

        float width = 1000.0;
        float height = 50.0;
        float tPos = 0.0;

        /*if(rayPos.z <= -5.0 + height && rayPos.z >= -6.0 && rayPos.x >= -(width/2.0) && rayPos.x <= (width/2.0) && rayPos.y >= -(width/2.0) && rayPos.y <= (width/2.0) ){
            vec4 terrainHeight = Texel(heightmap, vec2( (rayPos.x + (width/2.0))/width, (rayPos.y + (width/2.0) )/width) );
            if(rayPos.z <= terrainHeight.x*height - 5.0){
                pixel = HSLtoRGB(vec4(terrainHeight.x, 1.0, 0.5, 1.0) );
                break;
            }
        }*/
        if(rayPos.z < height*waterHeight + tPos){
            pixel = vec4(0.1, 0.1, 1.0, 1.0);
            //break;
        }
        if(rayPos.z <= tPos + height && rayPos.z >= tPos - (dist-0.5)/lod){
            vec4 terrainHeight = Texel(heightmap, vec2(mod(rayPos.x + width/2, width)/width, mod(rayPos.y + width/2.0, width)/width) );
            if(rayPos.z <= terrainHeight.x*height + tPos){
                pixel = HSLtoRGB(vec4(terrainHeight.x, 1.0, 0.5, 1.0) );
                break;
            }
        }
        if(rayPos.z <= -10.0){
            pixel = Texel(testTexture, vec2(mod(rayPos.x + 1.0, 2.0)/2.0, mod(rayPos.y + 1.0, 2.0)/2.0) );
            break;
        }
        if(manhattan(rayPos, vec3(10.0, 0.0, 2.0) ) <= 2.0){
            pixel = HSLtoRGB(vec4(mod(50 * pythag(rayPos, vec3(10.0, 0.0, 0.0) ), 1.0), 1.0, 0.5, 1.0) );
            break;
        }

        //pixel = HSLtoRGB(vec4(mod(manhattan(rayPos, vec3(10.0, 0.0, 0.0) ), 1.0), 1.0, 0.5, 1.0) );

        /*if(rayPos.x >= 10.0 && rayPos.x <= 11.0 && rayPos.y >= -11.0 && rayPos.y <= 11.0 && rayPos.z >= -11.0 && rayPos.z <= 11.0){
            if(abs(rayPos.y) > 5 || rayPos.z > 5){
                pixel = vec4(1.0, 0.0, 0.0, 1.0);
                break;
            }
        }
        else if(rayPos.x <= -10.0 && rayPos.x >= -11.0 && rayPos.y >= -11.0 && rayPos.y <= 11.0 && rayPos.z >= -11.0 && rayPos.z <= 11.0){
            pixel = vec4(0.0, 1.0, 0.0, 1.0);
            break;
        }
        else if(rayPos.y >= 10.0 && rayPos.y <= 11.0 && rayPos.x >= -11.0 && rayPos.x <= 11.0 && rayPos.z >= -11.0 && rayPos.z <= 11.0){
            pixel = vec4(0.0, 0.0, 1.0, 1.0);
            break;
        }
        else if(rayPos.y <= -10.0 && rayPos.y >= -11.0 && rayPos.x >= -11.0 && rayPos.x <= 11.0 && rayPos.z >= -11.0 && rayPos.z <= 11.0){
            pixel = vec4(1.0, 1.0, 0.0, 1.0);
            break;
        }
        else if(rayPos.z >= 10.0 && rayPos.z <= 11.0 && rayPos.y >= -11.0 && rayPos.y <= 11.0 && rayPos.x >= -11.0 && rayPos.x <= 11.0){
            pixel = vec4(0.0, 1.0, 1.0, 1.0);
            break;
        }
        else if(rayPos.z <= -10.0 && rayPos.z >= -11.0 && rayPos.y >= -11.0 && rayPos.y <= 11.0 && rayPos.x >= -11.0 && rayPos.x <= 11.0){
            pixel = vec4(1.0, 0.0, 1.0, 1.0);
            break;
        }*/

        if(rayPos.z + rotPreCalc[1].x >= pos.z && rayPos.z > height + -5.0){
            pixel = vec4(0.24, 0.712, 0.865, 1.0);
            break;
        }
    }
    pixel = lerp(pixel, vec4(0.24, 0.712, 0.865, 1.0), pow(bounds( (dist)/rendDist, 0, 1), 4) );

    return pixel;
}
