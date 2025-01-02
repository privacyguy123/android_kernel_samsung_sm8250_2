LLVM=$(pwd)/toolchain/gcc/bin/

LLVM_ENV="CROSS_COMPILE=$(echo $LLVM)aarch64-linux-gnu- CROSS_COMPILE_COMPAT=$(echo $LLVM)arm-linux-gnueabi- CLANG_DIR=$LLVM LLVM=1 LLVM_IAS=1"

KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

rm -f AnyKernel3/Image

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 $LLVM_ENV vendor/r8q_eur_openx_defconfig

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 $LLVM_ENV

cp -f out/arch/arm64/boot/Image AnyKernel3/
cd AnyKernel3
zip -r9 Aeretrea-r8q.zip .