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

# create plugins dir inside OUTPUT_DIR
mkdir -p $OUTPUT_DIR/plugins

# define system dlls to exclude (to ignore)
EXCLUDED_DLLS="CRYPT32.dll|IPHLPAPI.DLL|MSWSOCK.dll|SHLWAPI.dll|KERNEL32.dll|USER32.dll|GDI32.dll|ADVAPI32.dll|SHELL32.dll|WS2_32.dll|ole32.dll|COMCTL32.dll|msvcrt.dll"

# define additional dlls to copy
ADDITIONAL_DLLS=("icudt58.dll" "icuuc58.dll" "icuin58.dll" "Qt5PrintSupport.dll" "Qt5Sql.dll")

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

        # search system dirs first (excluding gcc directories)
        dep_path=$(find /usr/lib/$HOST /usr/$HOST/lib -name "$dep" -print -quit)

        if [[ -n "$dep_path" ]]; then
            echo "found in system path: $dep_path"
        else
            echo "not found in system path"
        fi

        # now search gcc dirs, specifically -posix subdirs
        if [[ -z "$dep_path" ]]; then
            dep_path=$(find /usr/lib/gcc/$HOST/*-posix/ -type f -name "$dep" -print -quit)

            if [[ -n "$dep_path" ]]; then
                echo "found in gcc -posix dir: $dep_path"
            else
                echo "not found in gcc -posix dir"
            fi
        fi

        # fallback to custom depend dir if needed
        if [[ -z "$dep_path" && -d "$DEPEND_DIR/$HOST" ]]; then
            echo "searching in custom depend dir: $DEPEND_DIR/$HOST"
            dep_path=$(find "$DEPEND_DIR/$HOST" -name "$dep" -print -quit)

            if [[ -n "$dep_path" ]]; then
                echo "found in custom depend dir: $dep_path"
            else
                echo "not found in custom depend dir"
            fi
        fi

        # copy if found
        if [[ -n "$dep_path" ]]; then
            cp -u "$dep_path" $OUTPUT_DIR/
            echo "copied: $dep_path -> $OUTPUT_DIR/"
        else
            echo "warning: $dep not found for $exe"
        fi
    done
done

# copy additional dlls from depends/$HOST
for dll in "${ADDITIONAL_DLLS[@]}"; do
    dep_path=$(find "$DEPEND_DIR/$HOST" -name "$dll" -print -quit)
    if [[ -n "$dep_path" ]]; then
        cp -u "$dep_path" $OUTPUT_DIR/
        echo "copied additional dll: $dep_path -> $OUTPUT_DIR/"
    else
        echo "warning: $dll not found in custom depend dir"
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
