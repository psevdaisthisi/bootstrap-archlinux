# Arch Linux notes

## Software Update

#### AUR
- Check for updates: `$ git pull`
- Install version at checked-out commit: `$ makepkg -sirc`

### Pacman
- Refresh: `$ sudo pacman -Sy`
- List outdated: `$ pacman -Qu`
- Update: `$ sudo pacman -Sy`

### pip
- List outdated: `$ pip list --user --outdated`
- Update: `$ pip install --user --upgrade <pkg>...`

### neovim
- Update Plug's plugins: `$ nvim +PlugUpgrade +PlugClean +PlugUpdate +qa`
- Update Coc's plugins: `$ nvim +CocUpdateSync +qa`

### NodeJS/NVM
- List latest LTS: `$ nvm ls-remote --lts`
- Install specific LTS: `$ nvm install --lts=<name|version>`

## Desktop Chords (sxhkd)

#### Windows
| Chord                   | Action                                            |
|:-----------------------:|---------------------------------------------------|
| `Win-{h,j,k,l}`         | Focus left, down, up, right.                      |
| `Win-{q,S-q}`           | Close/Kill.                                       |
| `Win-Tab`               | Focus last.                                       |
| `Win-{p,i,o}`           | Focus last, previous, next.                       |
| `Win-S-{h,j,k,l}`       | Swap with window at the left, down, up, right.    |
| `Win-C-{h,j,k,l}`       | Pre-select area (left, down, up, right).          |
| `Win-v`                 | Move focused window to pre-selected area.         |
| `Win-mouse1 (drag)`     | Move focused floating window.                     |
| `Win-mouse2 (drag)`     | Resize focused floating window.                   |
| `Win-S-[0-9]`           | Send window to _nth_ desktop.                     |
| `Win-{a,s,w,d}`         | Send window to monitor left, down, up, right.     |
| `Win-backslash`         | Flash focused.                                    |
| `Win-apostrophe`        | Swap window with the largest one.                 |
| `Win-u`                 | Jump to oldest urgent window.                     |
| `Win-f or Win-C-mouse1` | Toggle floating.                                  |
| `Win-t or Win-C-mouse2` | Toggle tiled.                                     |
| `Win-z or Win-C-mouse3` | Toggle fullscreen.                                |
| `Win-S-f`               | Toggle all floating.                              |
| `Win-S-t`               | Toggle all tiled.                                 |
| `Win-{m,S-m}`           | Hide/Unhide.                                      |
| `Win-{+,-}`             | Rotate tiled windows clockwise/counter-clockwise. |
| `Win-M-{h,j,k,l}`       | Increase window area (left, down, up, right).     |
| `Win-M-{h,j,k,l}`       | Decrease window area (left, down, up, right).     |

#### Desktops
| Chord           | Action                                       |
|:---------------:|----------------------------------------------|
| `Win-[0-9]`     | Focus _nth_ desktop.                         |
| `Win-S-{p,i,o}` | Focus last, previous, next.                  |
| `Win-S-{a,d}`   | Swap desktop with the one on the left/right. |

#### Monitors
| Chord       | Action              |
|:-----------:|---------------------|
| `Win-comma` | Focus next monitor. |

#### System
| Chord         | Action                              |
|:-------------:|-------------------------------------|
| `Win-Enter`   | Start new Alacritty instance.       |
| `Win-S-Enter` | Start larger Alacritty instance.    |
| `Win-Space`   | Start Rofi.                         |
| `Win-e`       | Start new file explorer instance.   |
| `Win-S-n`     | Start new Firefox private instance. |
| `Win-Escape`  | Restart sxhkd.                      |
| `Win-C-S-r`   | Restart bspwm.                      |
| `Win-C-S-p`   | Power-off.                          |
| `Win-C-S-s`   | Sleep.                              |
| `Win-C-S-l`   | Lock.                               |
| `PrintSrc`    | Start the screenshot tool.          |

## Tmux

#### Panes
| Chord           | Action                          |
|:---------------:|---------------------------------|
| `M-{h,j,k,l}`   | Select pane left,down,up,right. |
| `M-{a,s,d,f}`   | Resize pane left,down,up,right. |
| `C-M-{a,s,d,f}` | Swap pane left,down,up,right.   |
| `M-z`           | Zoom.                           |

#### Windows
| Chord         | Action                            |
|:-------------:|-----------------------------------|
| `M-Enter`     | New window.                       |
| `M-[0-9]`     | Select nth window.                |
| `M-{i,o,p}`   | Select previous,next,last window. |
| `C-M-{i,o}`   | Swap previous,next.               |
| `M-{h,j,k,l}` | Split left,down,up,right.         |

#### Miscellaneous
| Chord       | Action                      | Note |
|:-----------:|-----------------------------|-|
| `M-Space`   | Next layout.                |-|
| `C-M-Space` | Previous layout.            |-|
| `M-v`       | Enter copy mode.            |-|
| `v`         | Begin selection.            | (in copy mode) |
| `S-v`       | Toggle rectangle selection. | (in copy mode) |
| `y`         | Copy to clipboard.          | (in copy mode) |
| `Esc`       | Exit copy mode.             | (in copy mode) |
| `M-Esc`     | Reload configuration.       |-|
| `M-S-:`     | Tmux command prompt.        |-|
