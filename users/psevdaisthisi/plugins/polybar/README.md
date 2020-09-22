## Polytimer
A configurable countdown timer for Polybar.

### Highlights
- No dynamic libraries dependencies beyond `libc`.
- ~20K binary size when compiled with `-O3 -Wall -Wextra`.

### Setup
- Compile [`polytimer.c`](polytimer.c) and place it somewhere in the filecsystem.  
  Example: `gcc polytimer.c -Wall -Wextra -O3 -march=native -o ~/.local/bin/polytimer`
- Create a module in your Polybar configuration. Notice that it creates a
  _Named Pipe_, which is later used to send commands to polytimer.
  Its location is up to you.
  ```ini
  [module/polytimer]
  type = custom/script
  exec = mkfifo ~/.cache/polybar/fifo; ~/.local/bin/polytimer ~/.cache/polybar/fifo
  tail = true
  format = <label>
  click-left = echo "left-click" > ~/.cache/polybar/fifo
  click-right = echo "right-click" > ~/.cache/polybar/fifo
  click-middle = echo "middle-click" > ~/.cache/polybar/fifo
  scroll-up = echo "scroll-up" > ~/.cache/polybar/fifo
  scroll-down = echo "scroll-down" > ~/.cache/polybar/fifo
  ```

### Usage
