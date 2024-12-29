#!/bin/bash
OUTPUT_DIR="package"
DEPEND_DIR="$PWD/depends"
# ensure HOST is set
if [[ -z "$HOST" ]]; then
    echo "error: HOST is not set"
    exit 1
fi
# create output dir
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR
# define system dlls to exclude (to ignore)
EXCLUDED_DLLS="CRYPT32.dll|IPHLPAPI.DLL|MSWSOCK.dll|SHLWAPI.dll|KERNEL32.dll|USER32.dll|GDI32.dll|ADVAPI32.dll|SHELL32.dll|WS2_32.dll|ole32.dll|COMCTL32.dll|msvcrt.dll"
# define additional dlls to copy
ADDITIONAL_DLLS=("icudt58.dll" "icuuc58.dll" "icuin58.dll" "Qt5PrintSupport.dll" "Qt5Sql.dll" "libwinpthread-1.dll")

# Function to search for a DLL in all possible locations
find_dll() {
    local dll="$1"
    local dep_path=""
    
    # Search system dirs first (excluding gcc directories)
    dep_path=$(find /usr/lib/$HOST /usr/$HOST/lib -name "$dll" -print -quit)
    if [[ -n "$dep_path" ]]; then
        echo "Found in system path"
        echo "$dep_path"
        return 0
    fi
    
    # Search gcc dirs, specifically -posix subdirs
    dep_path=$(find /usr/lib/gcc/$HOST/*-posix/ -type f -name "$dll" -print -quit)
    if [[ -n "$dep_path" ]]; then
        echo "Found in gcc -posix dir"
        echo "$dep_path"
        return 0
    fi
    
    # Search custom depend dir if needed
    if [[ -d "$DEPEND_DIR/$HOST" ]]; then
        dep_path=$(find "$DEPEND_DIR/$HOST" -name "$dll" -print -quit)
        if [[ -n "$dep_path" ]]; then
            echo "Found in custom depend dir"
            echo "$dep_path"
            return 0
        fi
    fi
    
    echo "Not found anywhere"
    return 1
}

echo "packaging for host: $HOST"
# copy executables
find src/.libs -name "*.exe" -exec cp {} $OUTPUT_DIR/ \;
# process each exe
for exe in $OUTPUT_DIR/*.exe; do
    echo "processing: $exe"
    # find dependencies
    deps=$($HOST-objdump -p "$exe" | grep "DLL Name" | awk '{print $3}' | grep -Ev "$EXCLUDED_DLLS")
    echo "dependencies found: $deps"
    # copy dependencies
    for dep in $deps; do
        echo "searching for: $dep"
        # Get both status and path
        location=$(find_dll "$dep")
        # Get the last line as the path
        dep_path=$(echo "$location" | tail -n 1)
        
        if [[ -f "$dep_path" ]]; then
            cp -u "$dep_path" $OUTPUT_DIR/
            echo "copied: $dep_path -> $OUTPUT_DIR/"
        else
            echo "warning: $dep not found for $exe"
        fi
    done
done

# copy additional dlls from all possible locations
for dll in "${ADDITIONAL_DLLS[@]}"; do
    echo "searching for additional dll: $dll"
    # Get both status and path
    location=$(find_dll "$dll")
    # Get the last line as the path
    dep_path=$(echo "$location" | tail -n 1)
    
    if [[ -f "$dep_path" ]]; then
        cp -u "$dep_path" $OUTPUT_DIR/
        echo "copied additional dll: $dep_path -> $OUTPUT_DIR/"
    else
        echo "warning: $dll not found"
    fi
done

# copy plugins from depends/$HOST/plugins
if [[ -d "$DEPEND_DIR/$HOST/plugins" ]]; then
    cp -r -u "$DEPEND_DIR/$HOST/plugins/"* $OUTPUT_DIR/
    echo "copied plugins from $DEPEND_DIR/$HOST/plugins to $OUTPUT_DIR/"
else
    echo "warning: no plugins directory found in custom depend dir"
fi

# strip executables
$HOST-strip $OUTPUT_DIR/*.exe
echo "packaged app in $OUTPUT_DIR"
