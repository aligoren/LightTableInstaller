#!/bin/bash
#title			:lt_install.sh
#description	:LightTable Installation Script
#author			:<goren.ali@yandex.com> Ali GOREN
#date			:2015-10-31
#version		:0.1
#usage			:chmod u+x, ./lt_install.sh
#notes			:progressFilt Source-> http://stackoverflow.com/a/4687912
#bash_version	:4.3.11(1)-release

if [ ! -d /opt/lighttable ]; then
	sudo mkdir /opt/lighttable
fi

function get_version()
{
	OIFS="$IFS"
	IFS=$'|'
	s=$(curl -s https://github.com/LightTable/LightTable/releases | grep "css-truncate-target" | sed 's/<span class=\"css-truncate-target\"">//' | sed 's/<\/span>/\|/')
	array=($s)
	IFS="$OIFS"

	echo $array | grep -Po '<span(\s+[^>]*)?>\K[^<]*'
}
lt_release=$(get_version) &> /dev/null

user="$(whoami)";
ltfname="lighttable-*";
launcher="/usr/share/applications/light-table.desktop";
lt_url="https://github.com/LightTable/LightTable/releases/download/${lt_release}/lighttable-${lt_release}-linux.tar.gz";

echo Downloading...;

progressfilt()
{
    local flag=false c count cr=$'\r' nl=$'\n'
    while IFS='' read -d '' -rn 1 c
    do
        if $flag
        then
            printf '%c' "$c"
        else
            if [[ $c != $cr && $c != $nl ]]
            then
                count=0
            else
                ((count++))
                if ((count > 1))
                then
                    flag=true
                fi
            fi
        fi
    done
}

sudo wget --progress=bar:force -O /home/${user}/Downloads/lighttable.tar.gz $lt_url 2>&1 | progressfilt;

echo Installation...;

sudo tar xzf /home/${user}/Downloads/lighttable.tar.gz -C /home/${user}/Downloads/;

sudo mv -v /home/${user}/Downloads/${ltfname}/* /opt/lighttable &> /dev/null;

header="[Desktop Entry]";
name="Name=Light Table";
icon="Icon=/opt/lighttable/resources/app/core/img/lticon.png";
gname="GenericName=The Next Generation Code Editor";
execfile="Exec=/opt/lighttable/light";
terminal="Terminal=false";
typeapp="Type=Application";
categories="Categories=Development;TextEditor;Application;Utility;";

cat << EOF | sudo tee ${launcher} &> /dev/null
${header}
${name}
${icon}
${gname}
${execfile}
${terminal}
${typeapp}
${categories}
EOF


sudo rm /home/${user}/Downloads/lighttable.tar.gz;
sudo rm -rf /home/${user}/Downloads/${ltfname};

echo Installation Complete...;
read -p "Light Table is run from the terminal? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    /opt/lighttable/light &> /dev/null
	sleep 2
	killall /opt/lighttable/light &> /dev/null
	exit 1
elif [[ $REPLY =~ ^[Nn]$ ]]
then
	exit 1
else
	echo "Only Y-y or N-n"
	exit 1
fi
