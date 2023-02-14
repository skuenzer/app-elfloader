# Unikraft ELF Loader

## Executing ELF binaries

`elfloader` currently supports statically linked position-independent (PIE)
executables compiled for Linux on x86_64. Dynamically linked PIE executables can
be chain loaded using the corresponding official dynamic loader
(e.g., `ld-linux-x86-64.so.2` from glibc). This loader is also recognized as a
statically linked PIE executable.

In this version, any executable can only be passed to an `elfloader` unikernel
via the initrd argument. The ELF executable is the initrd, which means that no
additional initrd can be used as the root filesystem. Any additional filesystem
content must be passed via 9pfs.

### Static-PIE ELF executable
A static PIE executable can be simply handed over as initrd
([`qemu-guest`](https://github.com/unikraft/unikraft/tree/staging/support/scripts)):
```sh
$ qemu-guest -k elfloader_kvm-x86_64 -i /path/to/elfprogram \
             -a "<application arguments>"
```
Any application arguments are passed via kernel argument to the application.
Environment variables cannot be set, currently.

### Dynamically linked ELF executable
A dynamically linked PIE executable must be placed in a 9pfs root file system
along with its library dependencies. You can use `ldd` to list the dynamic
libraries on which the application depends in order to start.
Please note that the VDSO (here: `linux-vdso.so.1`) is provided by the Linux
kernel and is not present on the host filesystem. Please ignore this file.
```sh
$ ldd helloworld
	linux-vdso.so.1 (0x00007ffdd695d000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007efed259f000)
	/lib64/ld-linux-x86-64.so.2 (0x00007efed2787000)
```

A populated root filesystem may look like:
```
rootfs/
├── libc.so.6
└── helloworld
```

Because the official dynamic loader maps the application and libraries into
memory, the `elfloader` unikernel must be configured with `posix-mmap` or
`ukmmap`. In addition, you must include `vfscore` in the build and do the
following configuration: Under `Library Configuration -> vfscore: Configuration`
select `Automatically mount a root filesystem`, set `Default root filesystem` to
`9PFS`, and optionally set `Default root device` to `fs0`. This last option
simplifies the use of the `-e` parameter of `qemu-guest`.

A dynamically linked application (here: [`/helloworld`](./example/helloworld))
can then be started with
([`qemu-guest`](https://github.com/unikraft/unikraft/tree/staging/support/scripts)):
```sh
> qemu-guest -k elfloader_kvm-x86_64 -i /lib64/ld-linux-x86-64.so.2 -e rootfs/ \
            -a "--library-path / /helloworld <application arguments>"
```
Please note that environment variables cannot be set, currently.
