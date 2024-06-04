#!/bin/bash

if [[ $(id -u) != "0" ]]
then
    printf "\n\nError: Current user does not have root perms\n\n"
    exit
fi

THEME_DIR="/boot/grub/themes/grub_gtg"
fontsize=23

mkdir -p "/boot/grub/themes/grub_gtg"

printf "\n - Making fonts...\n"
if command -v grub-mkfont >> /dev/null; then
	grub-mkfont -s 20 -b ./assets/fonts/BankGothic.ttf -o "/boot/grub/themes/grub_gtg"/bankgothic.pf2
elif command -v grub2-mkfont >> /dev/null; then
	grub2-mkfont -s 20 -b ./assets/fonts/BankGothic.ttf -o "/boot/grub/themes/grub_gtg"/bankgothic.pf2
else 
	printf "\n - grub font maker doesn't exist using the default font\n"
    cp ./assets/fonts/bankgothic.pf2 "/boot/grub/themes/grub_gtg"/bankgothic.pf2
fi

printf "\n - Copying assets...\n"
cp ./assets/images/background.png "/boot/grub/themes/grub_gtg"/background.png
cp ./assets/menu/menu_*.png "/boot/grub/themes/grub_gtg"/
cp ./assets/selection/select_*.png "/boot/grub/themes/grub_gtg"/
cp ./assets/scrollbar/scrollbar_thumb_c.png "/boot/grub/themes/grub_gtg"/

printf "\n - Copying theme.txt...\n"
cp ./assets/theme.txt "/boot/grub/themes/grub_gtg"/

printf "\n - Changing the grub default config \n"
sed -i 's/.*GRUB_THEME=.*//' /etc/default/grub
echo "GRUB_THEME="/boot/grub/themes/grub_gtg"/theme.txt" >> /etc/default/grub

printf "\n - Adding some custom menuentries...\n"
if [ ! -f /etc/grub.d/40_custom ]; then
    printf "\n - 40_custom doesn't exist creating...\n"
    touch /etc/grub.d/40_custom
    chmod +x /etc/grub.d/40_custom
    echo "#!/bin/sh" >> /etc/grub.d/40_custom
    echo "exec tail -n +3 \$0" >> /etc/grub.d/40_custom
fi 
 
echo 'menuentry "Reboot" { reboot }' >> /etc/grub.d/40_custom
echo 'menuentry "Shut Down" { halt }' >> /etc/grub.d/40_custom

printf "\n - Updating grub config...\n\n"
if command -v update-grub >> /dev/null; then
  update-grub                        # debian based distros
elif command -v grub-mkconfig >> /dev/null; then
  grub-mkconfig -o /boot/grub/grub.cfg    # most other distros
elif command -v grub2-mkconfig >> /dev/null; then
  if command -v zypper >> /dev/null; then       
    grub2-mkconfig -o /boot/grub2/grub.cfg    # opensusee
  elif command -v dnf; then          
    grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg   # fedora
  fi
fi
