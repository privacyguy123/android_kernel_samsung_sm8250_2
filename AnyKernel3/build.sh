#!/bin/bash

mkdir out

GCC_ENV="CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_COMPAT=arm-linux-gnueabihf-"

LLVM=~/clangr47/bin/

LLVM_ENV="CROSS_COMPILE=$(echo $LLVM)aarch64-linux-gnu- CROSS_COMPILE_COMPAT=$(echo $LLVM)arm-linux-gnueabi- CLANG_DIR=$LLVM LLVM=1 LLVM_IAS=1"

KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

echo "**********************************"
echo "Select compiler"
echo "(1) GCC"
echo "(2) LLVM"
read -p "Selected compiler: " compiler

if [ $compiler == "1" ]; then
	COMPILER_ENV=$GCC_ENV

	echo "
################# Compiling with GCC #################
"

elif [ $compiler == "2" ]; then
	COMPILER_ENV=$LLVM_ENV

echo "
################# Compiling with LLVM #################
"
fi

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 $COMPILER_ENV \
	r8q_defconfig > /dev/null 2>&1

for i in "$@"; do
	case $i in
	pgo)
	   echo "
################# Compiling with PGO #################
"

	    KERNEL_MAKE_ENV="$KERNEL_MAKE_ENV CONFIG_PGO=y"
	;;

	lto)
	    echo "
################# Compiling GCC LTO build #################
"
	    scripts/configcleaner "
CONFIG_LTO_GCC
CONFIG_HAVE_ARCH_PREL32_RELOCATIONS
"
	    echo "CONFIG_LTO_GCC=y
" >> out/.config
	;;

	esac
done

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 $COMPILER_ENV vendor/r8q_eur_openx_defconfig

DATE_START=$(date +"%s")

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 $COMPILER_ENV

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 $COMPILER_ENV dtbs

IMAGE="out/arch/arm64/boot/Image"
DTB_OUT="out/arch/arm64/boot/dts/vendor/qcom"

cat $DTB_OUT/*.dtb > AnyKernel3/kona.dtb

#patch -p1 --merge < patches/freqtable.diff

#make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 $COMPILER_ENV dtbs

#cat $DTB_OUT/*.dtb > AnyKernel3/kona-perf.dtb

#patch -p1 -R --merge < patches/freqtable.diff

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))

echo "Time wasted: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."

if [[ -f "$IMAGE" ]]; then
	rm AnyKernel3/*.zip > /dev/null 2>&1
	cp $IMAGE AnyKernel3/Image
	cd AnyKernel3
	zip -r9 Aeretrea-r8q.zip .
fi
