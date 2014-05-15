#!/bin/bash
# script for switching to Oracle java from OpenJDK, provides as-is.
# author: Igor Yozhikov <iyozhikov#mirantis.com>
# May 2014
declare -A APPS
declare -A LIBS
BIN_DIR="/usr/bin"
APPS["appletviewer"]="${BIN_DIR}/appletviewer"
APPS["idlj"]="${BIN_DIR}/idlj"
APPS["jar"]="${BIN_DIR}/jar"
APPS["jarsigner"]="${BIN_DIR}/jarsigner"
APPS["java"]="${BIN_DIR}/java"
APPS["javac"]="${BIN_DIR}/javac"
APPS["javah"]="${BIN_DIR}/javah"
APPS["javap"]="${BIN_DIR}/javap"
APPS["javadoc"]="${BIN_DIR}/javadoc"
APPS["javafxpackager"]="${BIN_DIR}/javafxpackager"
APPS["jcmd"]="${BIN_DIR}/jcmd"
APPS["jconsole"]="${BIN_DIR}/jconsole"
APPS["jcontrol"]="${BIN_DIR}/jcontrol"
APPS["jdb"]="${BIN_DIR}/jdb"
APPS["jexec"]="${BIN_DIR}/jexec"
APPS["jhat"]="${BIN_DIR}/jhat"
APPS["jinfo"]="${BIN_DIR}/jinfo"
APPS["jjs"]="${BIN_DIR}/jjs"
APPS["jmap"]="${BIN_DIR}/jmap"
APPS["jps"]="${BIN_DIR}/jps"
APPS["jrunscript"]="${BIN_DIR}/jrunscript"
APPS["jsadebugd"]="${BIN_DIR}/jsadebugd"
APPS["jstack"]="${BIN_DIR}/jstack"
APPS["jstat"]="${BIN_DIR}/jstat"
APPS["jstatd"]="${BIN_DIR}/jstatd"
APPS["jvisualvm"]="${BIN_DIR}/jvisualvm"
APPS["keytool"]="${BIN_DIR}/keytool"
APPS["native2ascii"]="${BIN_DIR}/native2ascii"
APPS["orbd"]="${BIN_DIR}/orbd"
APPS["pack200"]="${BIN_DIR}/pack200"
APPS["policytool"]="${BIN_DIR}/policytool"
APPS["rmid"]="${BIN_DIR}/rmid"
APPS["rmiregistry"]="${BIN_DIR}/rmiregistry"
APPS["servertool"]="${BIN_DIR}/servertool"
APPS["tnameserv"]="${BIN_DIR}/tnameserv"
APPS["unpack200"]="${BIN_DIR}/unpack200"
LIBS["mozilla-javaplugin.so"]="/usr/lib/mozilla/plugins/libjavaplugin.so libnpjp2.so"
LIBS["javaplugin"]="/usr/lib64/browser-plugins/javaplugin.so libnpjp2.so"
NEW_JAVA_HOME=''
#Starting up
if [ $# -eq 0 ]; then
  echo "Usage: $0 /path/to/new/java/directory"
  exit 1
else
  if [ -n $1 ] && [ -d $1 ] && [ -d "$1/bin" ] && [ -d "$1/jre" ]; then
        NEW_JAVA_HOME=$1
  else
    echo "$1 is not a directory!"
    exit 1
  fi
fi
NEW_JAVA_HOME=$(echo ${NEW_JAVA_HOME} | sed 's/\/$//')
NEW_JAVA_HOME_BIN="${NEW_JAVA_HOME}/bin"
PRIORITY=1
#counter
cnt=0
# 
#Updating libs
for LIB in ${!LIBS[*]} ; do
  echo "Updating lib \"$LIB\"..."
  link=$(echo ${LIBS[$LIB]}| awk '{print $1}')
  filename=$(echo ${LIBS[$LIB]}| awk '{print $2}')
  full_path_to_lib=$(find ${NEW_JAVA_HOME}/jre/lib/ -name $filename)
  if [ -n "$full_path_to_lib" ]; then
    update-alternatives --install $link $LIB $full_path_to_lib $PRIORITY
    update-alternatives --set $LIB $full_path_to_lib
    cnt=$((cnt + 1))
  else
   	echo "ERR: Not found \"$filename\" under \"${NEW_JAVA_HOME}/jre/lib/\", skipping update for $LIB!"
  fi
done
#Updating apps
for APP in ${!APPS[*]} ; do
  echo "Updating application \"$APP\"..."
  if [ -f "${NEW_JAVA_HOME_BIN}/$APP" ]; then
    update-alternatives --install ${APPS[$APP]} $APP ${NEW_JAVA_HOME_BIN}/$APP $PRIORITY
    update-alternatives --set $APP ${NEW_JAVA_HOME_BIN}/$APP
    cnt=$((cnt + 1))
  elif [ -f "${NEW_JAVA_HOME}/jre/lib/$APP" ]; then
    update-alternatives --install ${APPS[$APP]} $APP ${NEW_JAVA_HOME}/jre/lib/$APP $PRIORITY
    update-alternatives --set $APP ${NEW_JAVA_HOME}/jre/lib/$APP
    cnt=$((cnt + 1))
  else 
    echo "ERR: Not found at \"${NEW_JAVA_HOME_BIN}/$APP\" or \"${NEW_JAVA_HOME}/jre/lib/$APP\", skipping update for $APP!"
  fi  
done
echo "Total alternatives updated: $cnt"
echo "Don't forget to set \$JAVA_HOME environment varable to the $NEW_JAVA_HOME !"
export JAVA_HOME=$NEW_JAVA_HOME
