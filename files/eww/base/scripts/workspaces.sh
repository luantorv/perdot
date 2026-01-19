#!/bin/bash

get_workspaces() {
    local active=$(hyprctl activeworkspace -j | jq -r '.id')
    local workspaces=$(hyprctl workspaces -j | jq -r '.[].id' | sort -n)
    
    echo "["
    local first=true
    for i in {1..10}; do
        if [ "$first" = false ]; then
            echo ","
        fi
        first=false
        
        local occupied="false"
        if echo "$workspaces" | grep -q "^${i}$"; then
            occupied="true"
        fi
        
        local is_active="false"
        if [ "$i" = "$active" ]; then
            is_active="true"
        fi
        
        echo -n "{\"id\": $i, \"occupied\": $occupied, \"active\": $is_active}"
    done
    echo "]"
}

get_workspaces

socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
    get_workspaces
done
