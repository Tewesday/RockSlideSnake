# Rock Slide Snake

A game written in Zig for the [WASM-4](https://wasm4.org) fantasy console. 
Requires a fork of WASM-4 that supports unix timestamp such as: https://github.com/Tewesday/wasm4.

## Playing

You can find and play the game online here:
https://tewesday.itch.io/rock-slide-snake

## Building

Build the cart by running:

```shell
zig build -Doptimize=ReleaseSmall
```

Then run it with:

```shell
w4 run zig-out/bin/cart.wasm
```

For more info about setting up WASM-4, see the [quickstart guide](https://wasm4.org/docs/getting-started/setup?code-lang=zig#quickstart).

