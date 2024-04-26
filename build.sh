#!/bin/bash

TC_DIR="$(pwd)/tc/clang"
AK3_DIR="$(pwd)/android/AnyKernel3"

kernel="out/arch/arm64/boot/Image.gz"

git clone --depth=1 -b 14 https://gitlab.com/ThankYouMario/android_prebuilts_clang-standalone "$TC_DIR"

export PATH="$TC_DIR/bin:$PATH"
export CROSS_COMPILE="$TC_DIR/bin/aarch64-linux-gnu-"
export CC="$TC_DIR/bin/clang"
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64
export TARGET_SOC=mt6877

make -C $(pwd) O=$(pwd)/out KCFLAGS=-w LLVM=1 LLVM_IAS=1 a34x_defconfig
make -C $(pwd) O=$(pwd)/out KCFLAGS=-w LLVM=1 LLVM_IAS=1 -j$(nproc --all)

if [ -f "$kernel" ]; then
	echo -e "\nKernel compiled succesfully! Zipping up...\n"
	if [ -d "$AK3_DIR" ]; then
		cp -r $AK3_DIR AnyKernel3
	elif ! git clone -q https://github.com/redznn/AnyKernel3 -b master; then
		echo -e "\nAnyKernel3 repo not found locally and couldn't clone from GitHub! Aborting..."
		exit 1
	fi
	cp $kernel AnyKernel3
	rm -rf out/arch/arm64/boot
	cd AnyKernel3
	git checkout master &> /dev/null
	zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder
	cd ..
	rm -rf AnyKernel3
	echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
	echo "Zip: $ZIPNAME"
else
	echo -e "\nCompilation failed!"
	exit 1
fi
