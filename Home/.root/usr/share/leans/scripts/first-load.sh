#!/bin/sh
username=$(whoami)

# Enable sound services
systemctl --user enable wireplumber.service pipewire.service pipewire-pulse.service

# Places folder creation
ln -s /home/$username/.config /home/$username/System/Places/Config
ln -s /home/$username/.local/share /home/$username/System/Places/Share
if [ -x /usr/bin/ssh ]; then
    ln -s /home/$username/.ssh/ /home/$username/System/SSH
fi
if [ -x /usr/bin/steam ]; then
    mkdir -p /home/$username/.local/share/Steam/
    ln -s /home/$username/.local/share/Steam/ /home/$username/System/Places/Steam
fi

# Create public folder
mkdir -p /home/$username/Public
ln -s /public /home/$username/Public/

# REGION LEANS CONFIGURATIONS UPDATE
TARGETS=("$HOME/.config" "$HOME/.local")

echo "Replacing @USERNAME@ with: $username"
echo

for dir in "${TARGETS[@]}"; do
  [ -d "$dir" ] || continue

  echo "Scanning $dir ..."

  # Find files containing the token, only text files
  grep -rlI --null '@USERNAME@' "$dir" | while IFS= read -r -d '' file; do
    echo "  -> Fixing: $file"
    sed -i "s/@USERNAME@/$username/g" "$file"
  done
done

echo
echo "Done."
# ENDREGION

rm -f /home/$username/.config/autostart/first-load.sh.desktop