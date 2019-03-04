# ₩onix

₩onix is my own operating system, which supports 64-bit. It is referenced by 『64비트 멀티코어 OS 원리와 구조』. For more details about this book, click [here](http://www.mint64os.pe.kr/).

## Prerequisite

To develop ₩onix on macOS or Linux(Ubuntu), it is necessary to install some programs.

> Suppose gcc is already installed.

### NASM

* macOS

```sh
$ brew install nasm
```

* Ubuntu 18.04 LTS
 
```sh
$ sudo apt install nasm
```

### QEMU

* macOS

```sh
$ brew install qemu
```

* Ubuntu 18.04 LTS

```sh
$ sudo apt install qemu
```

## Compile

```sh
$ make
```

## Execute

```sh
$ ./qemu-x86_64.bat
```

## LICENSE

₩onix is released under MIT License. See [LICENSE](LICENSE).
