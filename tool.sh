#!/bin/bash
#yes this script needs input sanitization

set -e
SIZE=2500
# TM2=$(realpath "./trimesh2/bin.Linux64")
MRG=$(realpath "./merge_obj.sh")
f_i=$(realpath ${1:-input.svg})
f_o=$(realpath ${2:-output.obj})
h_1=${3:-30}
h_2=${4:-6}
DR=$(mktemp -d)

cp "$f_i" "$DR/in.svg"
cd "$DR"
    echo "Moved to directory: $(pwd)"
    ffmpeg -y -width "$SIZE" -height "$SIZE" -i "in.svg" -filter_complex "[0:v]pad=width=2550:height=2550:x=(ow-iw)/2:y=(oh-ih)/2:color=#00000000,geq='r=if(max(lt(alpha(X\,Y)\,5)\,gt(r(X\,Y)+g(X\,Y)+b(X\,Y)\,25))\,0\,255):g=if(max(lt(alpha(X\,Y)\,5)\,gt(r(X\,Y)+g(X\,Y)+b(X\,Y)\,25))\,0\,255):b=if(max(lt(alpha(X\,Y)\,5)\,gt(r(X\,Y)+g(X\,Y)+b(X\,Y)\,25))\,0\,255):a=if(max(lt(alpha(X\,Y)\,5)\,gt(r(X\,Y)+g(X\,Y)+b(X\,Y)\,25))\,0\,255)',split[α][β];[α]floodfill=x=0:y=0:s0=0:s1=0:s2=0:s3=0:d0=255:d1=0:d2=0:d3=255,geq='r=255-if(gt(g(X\,Y)-b(X\,Y)-r(X\,Y)\,254)\,255\,0):g=255-if(gt(g(X\,Y)-b(X\,Y)-r(X\,Y)\,254)\,255\,0):b=255-if(gt(g(X\,Y)-b(X\,Y)-r(X\,Y)\,254)\,255\,0):a=255-if(gt(g(X\,Y)-b(X\,Y)-r(X\,Y)\,254)\,255\,0)'[γ];[β][γ]blend=all_expr='if(gt(B\,254)\,if(gt(A\,250)\,255\,128)\,0)',lutrgb='r=negval:g=negval:b=negval'" "α.bmp"
    ffmpeg -y -width "$SIZE" -height "$SIZE" -i "in.svg" -filter_complex "[0:v]pad=width=2550:height=2550:x=(ow-iw)/2:y=(oh-ih)/2:color=#00000000,geq='r=if(max(lt(alpha(X\,Y)\,5)\,gt(r(X\,Y)+g(X\,Y)+b(X\,Y)\,25))\,0\,255):g=if(max(lt(alpha(X\,Y)\,5)\,gt(r(X\,Y)+g(X\,Y)+b(X\,Y)\,25))\,0\,255):b=if(max(lt(alpha(X\,Y)\,5)\,gt(r(X\,Y)+g(X\,Y)+b(X\,Y)\,25))\,0\,255):a=if(max(lt(alpha(X\,Y)\,5)\,gt(r(X\,Y)+g(X\,Y)+b(X\,Y)\,25))\,0\,255)',split[α][β];[α]floodfill=x=0:y=0:s0=0:s1=0:s2=0:s3=0:d0=255:d1=0:d2=0:d3=255,geq='r=255-if(gt(g(X\,Y)-b(X\,Y)-r(X\,Y)\,254)\,255\,0):g=255-if(gt(g(X\,Y)-b(X\,Y)-r(X\,Y)\,254)\,255\,0):b=255-if(gt(g(X\,Y)-b(X\,Y)-r(X\,Y)\,254)\,255\,0):a=255-if(gt(g(X\,Y)-b(X\,Y)-r(X\,Y)\,254)\,255\,0)'[γ];[β][γ]blend=all_expr='if(gt(B\,254)\,if(gt(A\,250)\,255\,0)\,0)',lutrgb='r=negval:g=negval:b=negval'" "β.bmp"
    potrace -s "α.bmp" -o "α.svg"
    potrace -s "β.bmp" -o "β.svg"
    echo "linear_extrude(height=$h_1) import(\"α.svg\");" > "tool.scad"
    openscad -o "α.obj" "tool.scad"
    echo "translate([0, 0, $h_1-0.05]) linear_extrude(height=$h_2) import(\"β.svg\", \$fs=100);" > "tool.scad"
    openscad -o "β.obj" "tool.scad"
    
    cat <<< "mtllib obj.mtl
usemtl color_A
g group_A
s 0
    $(cat α.obj)" > α.obj
    cat <<< "usemtl color_B
g group_B
s 0
    $(cat β.obj)" > β.obj

    # $TM2/mesh_cat "α.obj" "β.obj" -o "γ.obj"
    $MRG "α.obj" "β.obj" "γ.obj"
    cp "γ.obj" "$f_o"
    
    # $TM2/mesh_filter "γ.obj" -bbcenter -bbnorm -scale 85 "$f_o"
    cd -
# rm -r "$DR"