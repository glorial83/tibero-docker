# 🐳 Tibero Docker Image

> 🌐️ English | [한국어](README.md)

This repository contains the configuration and build steps to run **Tibero 7.2.3** in a Docker environment.  
It outlines the key steps for containerization such as archive extraction, initial SQL execution, and user privilege setup.

> This repository is intended for demonstration or testing purposes in an unofficial environment.  
> Tibero is a registered trademark of TmaxSoft, and usage of the software is subject to its license terms.

## 🧱 Dockerfile Base Structure

- **Base Image**: [Rocky Linux 9.3](https://hub.docker.com/_/rockylinux)
- **Default Port**: `8629`

## 📦 Preparing Tibero 7.2.3

### Download Tibero

- [Tibero 7.2.3 for Linux (x86) 64-bit (4.18)](https://technet.tmax.co.kr/download2.do?filePath=/nas/technet/technet/upload/download/binary/tibero/7/0/&tempFileName=FILE-20250422-000002_250422162038_2.gz&attFileSeq=FILE-20250422-000002&fileSeqNo=2&fileName=tibero7-bin-FS02_PS03-linux64_4.18-292332-20250421060145.tar.gz&_StartOffset=0&_EndOffset=701957119&_printFileName=tibero7-bin-FS02_PS03-linux64_4.18-292332-20250421060145.tar.gz)

### Extract Archive and Split for GitHub Upload (100mb)

```bash
tar zcvf - ./tibero7 | split -b 100m - tibero.tar.gz
```

### Request Demo License

Apply for a demo license on [TmaxSoft TechNet](https://technet.tmax.co.kr/en/front/main/main.do), then overwrite the issued file to `./tibero7/license.xml`.

## 🛠️ Build & Run Docker Image

- **Build Image**

  ```bash
  docker build . -t gtibero7
  ```

- **Run Container**

  ```bash
  docker run -d --name gtibero7 --hostname tibero7 -p 8629:8629 gtibero7
  ```

  > **The `hostname` value used when applying for the license must match the one used during Docker container execution.**

- **Build and Run in One Step**

  ```bash
  docker rm gtibero7 && docker rmi gtibero7 && docker build . -t gtibero7 && docker run -d --name gtibero7 --hostname tibero7 -p 8629:8629 gtibero7
  ```

- **Access Container Terminal**
  ```bash
  docker exec -it gtibero7 /bin/bash
  [root@tibero7 tibero]# su - tibero
  ```

## 🔐 Database Credentials

```
Username : demo
Password : demo
Default Schema : demo
Database : tibero
Port : 8629

URL : jdbc:tibero:thin:@localhost:8629:tibero
```

## 🔁 How to Upgrade

1. Delete `./tibero7/tibero.tar.gza.*` files  
2. Delete `./tibero7/license.xml`  
3. Request new demo license from TechNet  
4. Place the issued license in `./tibero7/license.xml`  
5. Download Tibero package and split as `./tibero7/tibero.tar.gza.*`  
6. Rebuild and run Docker image

## 📎 Appendix

If you prefer manual installation, refer to the script below:

```bash
container> vi /tibero7/license/license.xml

container> vi ~/.profile
export TB_SID=tibero
export TB_HOME=/tibero7
export TB_CONFIG=$TB_HOME/config
export PATH=$PATH:$TB_HOME/bin:$TB_HOME/client/bin
export LD_LIBRARY_PATH=$TB_HOME/lib:$TB_HOME/client/lib

container> source ~/.profile

container> vi /tibero7/createDatabase.sql
create database "tibero"
user sys identified by tibero
maxinstances 8
maxdatafiles 100
character set MSWIN949
national character set UTF16
logfile
    group 1 'log001.log' size 50M,
    group 2 'log002.log' size 50M,
    group 3 'log003.log' size 50M
maxloggroups 255
maxlogmembers 8
noarchivelog
    datafile 'system001.dtf' size 100M autoextend on next 10M maxsize unlimited
    default temporary tablespace TEMP
    tempfile 'temp001.dtf' size 100M autoextend on next 10M maxsize unlimited
    extent management local autoallocate
    undo tablespace UNDO
    datafile 'undo001.dtf' size 200M autoextend on next 10M maxsize unlimited
    extent management local autoallocate
    SYSSUB
    datafile 'syssub001.dtf' size 10M autoextend on next 10M maxsize unlimited
    default tablespace USR
    datafile 'usr001.dtf' size 100M autoextend on next 10M maxsize unlimited
    extent management local autoallocate;

container> sh $TB_HOME/config/gen_tip.sh
container> mkdir -p /usr/bin/pstack
container> /tibero7/bin/tbboot nomount
container> tbsql sys/tibero @'/tibero7/createDemoUser.sql'
SQL> quit
container> /tibero7/bin/tbboot
container> sh $TB_HOME/scripts/system_install.sh
```

### Check installation logs

```bash
container> cat /tibero7/instance/tibero/log/system_init.log | grep "TBR-17001"
container> cat /tibero7/instance/tibero/log/system_init.log | grep "TBR-70004"
```

## 🔖 References

- [Official Installation Guide](https://technet.tmax.co.kr/upload/download/online/tibero/pver-20220224-000002/tibero_install/chapter_database_install.html#sect_install_manual_unix)
- [Official Installation Guide Appendix](https://technet.tmax.co.kr/upload/download/online/tibero/pver-20220224-000002/tibero_install/appendix_system_install_sh.html)
- [dimensigon/tibero-docker](https://github.com/dimensigon/tibero-docker)
