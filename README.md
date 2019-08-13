# ubi8-s2i-wasi
This project is source to image builder for WASM/WASI text format, and also be a runtime
for WebAssembly binaries. 

### What is this?
The idea is to enable OpenShift users to run WebAssembly binaries. These 
binaries could be written and distributed using any means suitable (C++, Rust, 
etc). This is particularly interesting for languages without runtimes like 
C/C++/Rust.

We could also provide a s2i builder that would take a WASM text format (wat)
and compile it and build an image of that (source to image).

### Why?
WebAssembly binaries are completely sandboxed, meaning that they only have 
access to the host machine's resources through WASI. There are other systems 
that are also sandboxed at the application level - for instance, Node through 
V8. The difference here is the level of control you have. On one side of the 
spectrum, V8 is completely sandboxed and does not offer a way to talk to host 
systems. Node is a way to open up V8 to allow it to take to the host system.
Unfortunately, Node completely opens up the host system to the application in 
an uncontrolled and unmanaged way.

WASI and the various runtimes allow for more fine-grained permission. For 
example, instead of allowing access to the host system's entire file system, 
a user can grant permissions to only a certain directory. Similar controls 
exist for networking and other system resource

The WebAssembly/WASI runtime is very lightweight in terms of overhead. Unlike 
Docker which also provides fine grained sandboxing, WebAssembly operates at the
application level not the OS userland level. This means WebAssembly programs 
can be started much more quickly and will consume much less resources both on 
the host system.

A completely sandboxed and lightweight environment can allow for more tightly
packing serverless applications on the same machine - allowing for serverless
providers to lower costs. Additionally, startup times should be much lower (theoretically on the order of 1-2 ms)

### Node.js WASI support
Node.js is currently working on providing WASI support, an implementation
of the WASI interface so that WASI can be run on Node.js. 
For example, if Node’s native modules were written in WebAssembly, then users
wouldn’t need to run node-gyp when they install apps with native modules, and
developers wouldn’t need to configure and distribute dozens of binaries.

Providing the s2i-image is more of a nice thing to provide to simple demos where
we save users from having to set up the compile toolchain and runtime.

I think the common use case would be that WebAssembly binaries are already 
available somewhere (perhaps npm) and specified as the build stage, downloaded
and added to the image, along with any security setting/resource configuration
that the application requires (remember that WASI can write to the file system
and also open TCP sockets and there permissions need to be configured explicitly).

```console
$ docker build -t ubi8-s2i-wasi .
```

```console
$ docker run -it ubi8-s2i-wasi /bin/bash
```
