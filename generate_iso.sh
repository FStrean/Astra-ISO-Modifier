#!/bin/bash

iso_name="Astra.iso"

#Монтирование образа и копирование файловой системы
mkdir mnt irmod cd
sudo mount -o loop iso/"$iso_name" mnt
rsync -a -H --exclude=TRANS.TBL mnt/. cd

#Создание папок под новые опции установки
mkdir cd/install.amd/auto
mkdir cd/install.amd/semiauto

#Копирование vmlinux в новосозданные папки
cp -f cd/install.amd/vmlinuz cd/install.amd/auto
cp -f cd/install.amd/vmlinuz cd/install.amd/semiauto

#Распаковка initrd, замена файла preseed.cfg и сборка для автоматической установки
cd irmod
sudo gzip -d < ../cd/install.amd/initrd.gz | sudo cpio --extract --make-directories --no-absolute-filenames
cp -f ../auto/preseed.cfg preseed.cfg
find . | sudo cpio -H newc --create | sudo gzip -9 > ../cd/install.amd/auto/initrd.gz

cd ..
rm -rf irmod
mkdir irmod

#Распаковка initrd, замена файла preseed.cfg и сборка для автоматической установки МКТ
cd irmod
sudo gzip -d < ../cd/install.amd/initrd.gz | sudo cpio --extract --make-directories --no-absolute-filenames
cp -f ../semiauto/preseed.cfg preseed.cfg
find . | sudo cpio -H newc --create | sudo gzip -9 > ../cd/install.amd/semiauto/initrd.gz

cd ..

#Создание новых опций и прописывание путей к ним
cp -f isolinux/menu.cfg cd/isolinux/menu.cfg
cp -f isolinux/auto.cfg cd/isolinux/auto.cfg
cp -f isolinux/semiauto.cfg cd/isolinux/semiauto.cfg
cp -f isolinux/en.tr cd/isolinux/en.tr
cp -f isolinux/ru.tr cd/isolinux/ru.tr

#Обновление файла хэша
cd cd
md5sum `find -follow -type f` > ./md5sum.txt
cd ..

#Генерация iso файла
genisoimage -o result/Astra.iso -r -J -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -eltorito-boot boot/grub/efi.img -no-emul-boot ./cd

#Очистка
umount mnt
rm -rf mnt
rm -rf irmod
rm -rf cd


if [[ -d /media/sf_temp ]]; then
    if [[ -f /media/sf_temp/Astra.iso ]]; then
        rm -f /media/sf_temp/Astra.iso
    fi
    mv result/Astra.iso /media/sf_temp
fi
