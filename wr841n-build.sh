#!/bin/bash

# Prerequisites: http://wiki.openwrt.org/doc/howto/buildroot.exigence
# Additionally JDK is needed

generate_buildenv() {
    # Prepare build enviroment
    mkdir openwrt_build
    cd openwrt_build
    git clone -b chaos_calmer git://github.com/openwrt/openwrt.git
    cd openwrt
}

dl_and_install_feeds() {
    # Download and install package feeds
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    rm -f .config .config.old
}

dl_and_update_config() {
    # Download and update .config
    wget -qO .config https://gist.githubusercontent.com/amq/84789ed42f7a27f2b0b0/raw
    make defconfig
}

optimize_luci() {
    dl_and_extract_apps() {
        wget -qO yuicompressor.jar https://github.com/yui/yuicompressor/releases/download/v2.4.8/yuicompressor-2.4.8.jar
        wget -qO compiler.zip http://dl.google.com/closure-compiler/compiler-latest.zip

        unzip -ojqq compiler.zip
        rm -f compiler.zip
    }

    # The following code is based on:
    # https://forum.openwrt.org/viewtopic.php?pid=183795#p183795
    # We might want to look at modifiying imgopt for our needs
    minify_css() {
        for file in $( find "feeds/luci" -iname '*.css' )
        do
            echo "$file"
            java -jar yuicompressor.jar -o "$file-min.css" "$file"
            mv "$file-min.css" "$file"
        done
    }

    optimize_js() {
        for file in $( find "feeds/luci" -iname '*.js' )
        do
            echo "$file"
            java -jar compiler.jar --compilation_level=SIMPLE_OPTIMIZATIONS --js="$file" --js_output_file="$file-min.js"
            mv "$file-min.js" "$file"
        done
    }

    dl_and_extract_apps
    minify_css
    optimize_js

    rm -f yuicompressor.jar compiler.jar
}

run_make() {
    # Compile firmware
    make -j "$(getconf _NPROCESSORS_ONLN 2> /dev/null)" V=s 2>&1 | tee build.log | grep -i error
    
    # Apply reghack
    wget -q http://luci.subsignal.org/~jow/reghack/reghack.c
    gcc -o reghack reghack.c
    chmod +x reghack
    ./reghack build_dir/*/root-ar71xx/lib/modules/*/cfg80211.ko
    ./reghack build_dir/*/root-ar71xx/lib/modules/*/ath.ko
    
    # Rebuild images to include reghack
    make -j "$(getconf _NPROCESSORS_ONLN 2> /dev/null)" V=s 2>&1 | tee build.log | grep -i error
}

generate_buildenv
dl_and_install_feeds
dl_and_update_config
optimize_luci
run_make
