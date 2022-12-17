# Basic CH32V003 RISCV Makefile project

Requirements:
 - xpack riscv toolchain
 Download from releases here, and add to your path.
 (https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/latest)

Set up udev rules for WCH link
```
sudo cp ./50-wch.rules   /etc/udev/rules.d  
sudo udevadm control --reload-rules
```

Make project
```
make
```


# Licence

Unless otherwise stated files are licensed as Apache-2.0

Files under `vendor/` are from openwch (https://github.com/openwch/ch32v003) Licensed under Apache-2.0
Makefile is based on an example here: https://github.com/gregdavill/CH32V307-makefile-example
