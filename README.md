# 🐳 Tibero Docker Image

> 🌐️ 한국어 | [English](README_en.md)

이 저장소는 **Tibero 7.2.3**을 Docker 환경에서 실행하기 위한 설정과 빌드 과정을 담고 있습니다.  
압축 해제, 초기 SQL 실행, 사용자 권한 설정 등 컨테이너화를 위한 주요 과정을 아래에 정리했습니다.

> 본 저장소는 데모 또는 테스트 목적의 비공식 환경 구성입니다.  
> Tibero는 TmaxSoft의 등록 상표이며, 해당 소프트웨어의 사용은 해당 소프트웨어의 라이선스 약관을 따릅니다.

## 🧱 Dockerfile 기본 구성

- **기본 이미지**: [Rocky Linux 9.3](https://hub.docker.com/_/rockylinux)
- **기본 포트**: `8629`

## 📦 Tibero 7.2.3 준비

### Tibero 다운로드

- [Tibero 7.2.3 for Linux (x86) 64-bit (4.18)](https://technet.tmax.co.kr/download2.do?filePath=/nas/technet/technet/upload/download/binary/tibero/7/0/&tempFileName=FILE-20250422-000002_250422162038_2.gz&attFileSeq=FILE-20250422-000002&fileSeqNo=2&fileName=tibero7-bin-FS02_PS03-linux64_4.18-292332-20250421060145.tar.gz&_StartOffset=0&_EndOffset=701957119&_printFileName=tibero7-bin-FS02_PS03-linux64_4.18-292332-20250421060145.tar.gz)

### 압축 해제 및 GitHub 업로드용 분할(100mb)

```bash
tar zcvf - ./tibero7 | split -b 100m - tibero.tar.gz
```

### 데모 라이선스 발급

[TmaxSoft TechNet](https://technet.tmax.co.kr/en/front/main/main.do)에서 데모 라이선스를 신청한 후, 발급된 파일을 `./tibero7/license.xml`에 덮어씌워 주세요.

## 🛠️ Docker 이미지 빌드 & 실행

- **이미지 빌드**

  ```bash
  docker build . -t gtibero7
  ```

- **컨테이너 실행**

  ```bash
  docker run -d --name gtibero7 --hostname tibero7 -p 8629:8629 gtibero7
  ```

  > **라이선스를 신청할 때 입력한 `hostname` 값은 Docker 실행 시에도 동일하게 설정되어야 합니다.**

- **빌드 후 실행까지 한 번에**

  ```bash
  docker rm gtibero7 && docker rmi gtibero7 && docker build . -t gtibero7 && docker run -d --name gtibero7 --hostname tibero7 -p 8629:8629 gtibero7
  ```

- **컨테이너 터미널 접속**
  ```bash
  docker exec -it gtibero7 /bin/bash
  [root@tibero7 tibero]# su - tibero
  ```

## 🔐 Database 접속정보

```
Username : demo
Password : demo
Default Schema : demo
Database : tibero
Port : 8629

URL : jdbc:tibero:thin:@localhost:8629:tibero
```

## 🔁 How to Upgrade

1. `./tibero7/tibero.tar.gza.*` 파일 삭제
2. `./tibero7/license.xml` 삭제
3. TechNet에서 Tibero 데모 라이선스 요청
4. 발급된 Tibero 데모 라이선스를 `./tibero7/license.xml`에 저장
5. Tibero 패키지 다운로드 및 분할 압축 하여 `./tibero7/tibero.tar.gza.*`에 저장
6. 도커 이미지 빌드 및 실행

## 📎 Appendix

수동 설치를 원하는 경우 아래 스크립트를 참고하세요

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

설치 로그 확인

```bash
container> cat /tibero7/instance/tibero/log/system_init.log | grep "TBR-17001"
container> cat /tibero7/instance/tibero/log/system_init.log | grep "TBR-70004"
```

## 🔖 References

- [공식 설치 가이드](https://technet.tmax.co.kr/upload/download/online/tibero/pver-20220224-000002/tibero_install/chapter_database_install.html#sect_install_manual_unix)
- [공식 설치 가이드 부록](https://technet.tmax.co.kr/upload/download/online/tibero/pver-20220224-000002/tibero_install/appendix_system_install_sh.html)
- [dimensigon/tibero-docker](https://github.com/dimensigon/tibero-docker)
