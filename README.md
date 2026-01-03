# Leans GEN
Ultra simple arch linux installation with KDE

### How to use (online installation version)
- Download the [arch linux iso](https://archlinux.org/download/)
- Create the flash usb my recommendation is using [Ventoy](https://www.ventoy.net/en/download.html)
- After boot connect to internet if you are not already connected [Arch Linux Wiki - IWD](https://wiki.archlinux.org/title/Iwd)
- After boot in the arch linux use the command ``sh -c "$(curl -sS https://raw.githubusercontent.com/LeandroTheDev/leans_gen/refs/heads/main/init.sh)"``

### How to use (offline installation mode)
- To do

### Tecnical Informations
- UEFI and Legacy is supported
- 3 Options to choose: Full Desktop: KDE Plasma 6 (IDE Only), Server: without IDE, Empty: Only bootloader
- Sound driver: Pipewire
- Boot manager: Grub, id: LeansGen
- If you accept the goodies from device configurations don't forget to use ``mangohud gamemoderun <gamename>`` or in steam launch parameters ``mangohud gamemoderun %command%``, and also don't forget to configure the mangohud using the program ``Goverlay`` (For Gamers)

### KDE Controls
- Next Desktop: ctrl + alt + tab
- Previous Desktop: ctrl + alt + shift + tab
- Task manager: ctrl + alt + del