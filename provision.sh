#!/bin/bash
MASTERHOST=workbench.local
MASTERUSER=root
MASTERHOME=/home/chip/
HOSTUSER=chip
HOSTNAME="$1"

BOLD="`tput bold` `tput setaf 4`"
UNBOLD="`tput rmso` `tput setaf 0`"

logger() {
  echo "$BOLD$@ $UNBOLD"
}

if [ "$UID" -ne "0" ]
then
  echo "Hey this is a root thing"
  echo ""
  echo "just root stuff ok"
fi

cd /home/$HOSTUSER

if [ "$HOSTNAME" == "" ]
then
  logger we require more vespene gas. or a hostname, as \$1.
  exit
fi


logger replacing NTC apt repository...
sed -i 's/opensource.nextthing.co/chip.jfpossibilities.com/gi' /etc/apt/sources.list

logger disabling apt key checks b/c jessie-backports...

echo 'Acquire::Check-Valid-Until "false";' >> /etc/apt/apt.conf.d/jessie-backports.conf




logger updating packages...
apt-get update

logger requirements...
apt-get install -y figlet git avahi-daemon avahi-utils libnss-mdns anacron || exit


if [ ! -e /home/$HOSTUSER/.ssh/id_rsa ] || [ ! -e ~/.ssh/id_rsa ]
then
  logger getting key... please enter password:
  scp -r $MASTERUSER@$MASTERHOST:$MASTERHOME.ssh /root/
  scp -r $MASTERUSER@$MASTERHOST:$MASTERHOME.ssh /home/$HOSTUSER/
  logger perms for ssh keys...
  chown -R $HOSTUSER /home/$HOSTUSER/.ssh
  chmod 700 /home/$HOSTUSER/.ssh
  chmod 700 /home/$HOSTUSER/.ssh/id_rsa

  chmod 700 ~/.ssh
  chmod 700 ~/.ssh/id_rsa

fi

if [ `ls /etc/NetworkManager/system-connections/| wc -l` -lt 2 ]
then
logger fetching network connections...
scp -r $MASTERUSER@$MASTERHOST:/etc/NetworkManager/system-connections/ /etc/NetworkManager/
fi


logger timezone...
# dpkg-reconfigure tzdata
scp -r $MASTERUSER@$MASTERHOST:/etc/localtime /etc/

logger locales...
apt-get -y install locales
scp -r $MASTERUSER@$MASTERHOST:/etc/locale.gen /etc/
/usr/sbin/locale-gen
localectl set-locale LANG=en_US.UTF-8
export LANG=en_US.UTF-8

logger hostname...

grep Debian /etc/motd > /dev/null
if [ "$?" == "0" ]
then
logger setting motd ...
echo "$HOSTNAME" | figlet -f `ls /usr/share/figlet/*.flf | sort -R | head -1` > /etc/motd
fi

grep EDITOR ~/.profile > /dev/null || ( logger adding EDITOR to ~/.profile... ; echo -e '\nexport EDITOR=nano\n' >> ~/.profile )
grep EDITOR /home/$HOSTUSER/.profile > /dev/null || ( logger adding EDITOR to /home/HOSTUSER/.profile... ;echo -e '\nexport EDITOR=nano\n' >> /home/$HOSTUSER/.profile )

logger fw_env.config...

echo '/dev/mtdblock3 0x0000 0x400000 0x4000'>/etc/fw_env.config

logger git configuration...
sudo -u $HOSTUSER git config --global user.email "$HOSTUSER@$HOSTNAME"
sudo -u $HOSTUSER git config --global user.name "$HOSTUSER@$HOSTNAME"

logger git repos...
cd /home/$HOSTUSER
mkdir git 2>/dev/null
cd git
logger chip-tools
if [ ! -d chip-tools ]
then
yes | git clone git@github.com:combs/chip-tools.git
fi
logger chip-trello
if [ ! -d chip-trello ]
then
yes | git clone git@github.com:combs/chip-trello.git
fi
cd /home/$HOSTUSER
logger perms for git repos...

chown -R $HOSTUSER git

# logger locking password...
# passwd -l $HOSTUSER
# passwd -l root


if [ ! -e /usr/local/etc/blink.cfg ]
then
  logger blink...
  sudo wget -O /usr/local/bin/blink.sh http://fordsfords.github.io/blink/blink.sh
  sudo chmod +x /usr/local/bin/blink.sh
  sudo wget -O /etc/systemd/system/blink.service http://fordsfords.github.io/blink/blink.service
  curl http://fordsfords.github.io/blink/blink.cfg | sed -e 's/BLINK_STATUS=1/BLINK_STATUS=0/' > /usr/local/etc/blink.cfg
  ln -s /usr/local/etc/blink.cfg /etc/blink.cfg
  sudo systemctl enable /etc/systemd/system/blink.service

fi

logger adding nopasswd to sudoers...
echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/nopasswd
chmod 0440 /etc/sudoers.d/nopasswd

logger disabling password authentication...
cat /etc/ssh/sshd_config | sed 's/^PasswordAuthentication yes/# PasswordAuthentication yes/' >> /tmp/sshd_config && cat /tmp/sshd_config > /etc/ssh/sshd_config && rm /tmp/sshd_config

logger setting hostname...
echo $HOSTNAME > /etc/hostname
cat /etc/hosts | sed -e "s/127.0.0.1.*chip.*/127.0.0.1 $HOSTNAME/" > /tmp/hostname && cat /tmp/hostname > /etc/hosts && rm /tmp/hostname

if [ ! -d /root/.axp209 ]
then
  logger setting up axp209 daemon...
  scp -r $MASTERUSER@$MASTERHOST:/etc/init.d/axp209 /etc/init.d/
  scp -r $MASTERUSER@$MASTERHOST:/root/.axp209 /root/
  /etc/init.d/axp209 start
  sudo update-rc.d ax209 defaults
fi

# crontab -u root -l > /tmp/crontab.root
# grep backup /tmp/crontab.root || ( logger adding backup to crontab... ; echo -e "\n# m h  dom mon dow   command\n0 5 * * 1 /home/$HOSTUSER/git/chip-tools/backup.sh" >> /tmp/crontab.root; crontab /tmp/crontab.root; rm /tmp/crontab.root )

ln -s /home/$HOSTUSER/git/chip-tools/backup.sh /etc/cron.weekly/backup
chown root:root /home/$HOSTUSER/git/chip-tools/backup.sh

crontab -u $HOSTUSER -l > /tmp/crontab.$HOSTUSER
grep git-puller /tmp/crontab.$HOSTUSER || ( logger adding git-puller.sh to $HOSTUSER crontab... ; echo -e "\n# m h  dom mon dow   command\n25 5,9,13,17,21,1 * * 1 /home/chip/git/chip-tools/git-puller.sh" >> /tmp/crontab.$HOSTUSER; crontab -u $HOSTUSER /tmp/crontab.$HOSTUSER; rm /tmp/crontab.$HOSTUSER )


logger install packages...
apt-get -y install i2c-tools psmisc python-pip python3-pip python3 psutils aptitude build-essential git autoconf libtool libdaemon-dev libasound2-dev libpopt-dev libconfig-dev libavahi-client-dev libssl-dev libsoxr-dev zlib1g-dev zlib1g python-dev python3.4 python3-pip figlet htop ffmpeg mplayer unzip gettext moreutils htop
logger update packages...
apt-get -y dist-upgrade

logger double check for uimage...
if [ ! -f "/boot/initrd.uimage" ]
then
cd /boot
IMG=`ls initrd.img* | tail -1`
UIMAGE=`echo $IMG | sed -e 's:img:uimage:'`
DESCRIPTION=`echo $IMG | sed -e 's:.img::'`
mkimage -A arm -T ramdisk -C none -n "$DESCRIPTION" -d "$IMG" "$UIMAGE"
ln -sf "$UIMAGE" initrd.uimage
fi

logger Hmm that\'s all I got
