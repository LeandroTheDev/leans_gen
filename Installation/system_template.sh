echo "Downloading system template..."
pacman -S git --noconfirm
cd /tmp
git clone --branch leansgen --single-branch https://github.com/LeandroTheDev/leans_gen.git
cp -r /tmp/leans_gen/Home/{.,}* /etc/skel
chmod 755 -R /etc/skel
rm -rf /tmp/leans_gen
chmod +x /etc/skel/Temporary/firstload.sh