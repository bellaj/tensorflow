#!/bin/sh
# Detects which OS and if it is Linux then it will detect which Linux Distribution.

OS=`uname -s`
REV=`uname -r`
MACH=`uname -m`
DIST='a'

if [ ${MACH} == 'x86_64' ]; 
then
 echo "Your Proc architecture is x86_64" 
else
 echo "TensorFlow is available only for 64 bit architechture"
 exit 0
fi


GetVersionFromFile()
{
	VERSION=`cat $1 | tr "\n" ' ' | sed s/.*VERSION.*=\ // `
}

wich_sys(){
    

if [ "${OS}" = "SunOS" ] ; then
	OS=Solaris
	ARCH=`uname -p`	
	echo "${OS} ${REV}(${ARCH} `uname -v`)"
	exit 0
elif [ "${OS}" = "AIX" ] ; then
	echo "${OS} `oslevel` (`oslevel -r`)" 
	exit 0
elif [ "${OS}" = "Linux" ] ; then
	KERNEL=`uname -r`
	if [ -f /etc/redhat-release ] ; then
		DIST='RedHat'
		PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
		REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
	elif [ -f /etc/SUSE-release ] ; then
		DIST='SUSE'
		REV=`cat /etc/SUSE-release | tr "\n" ' ' | sed s/.*=\ //`
	elif [ -f /etc/mandrake-release ] ; then
		DIST='Mandrake'
		PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
		REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
	elif [ -f /etc/debian_version ] ; then
		DIST="Debian "
		REV=`cat /etc/debian_version`

	elif [ -f /etc/arch-release ] ; then
		DIST="Archlinux"
		REV=`cat /etc/arch-release`
	 

	fi
	if [ -f /etc/UnitedLinux-release ] ; then
		DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
	fi
	
	OSSTR="${DIST} ${REV} ${PSUEDONAME}"

fi

 
echo  ${DIST}
}

 
echo "your system is a $(wich_sys)"


 
#################Python_detect(){
version=$(python -V 2>&1 | grep -Po '(?<=Python )(.+)')

if [[ -z "$version" ]]
then
    echo "No Python!" 
    pythonV=0
    ech "Install python first"
    exit 0

else
    pythonV=$version
fi

parsedVersion=$(echo "${version//./}")
if [[ "$parsedVersion" -lt "300" ]] #python version <3
then 
    pythonV=2
else
    pythonV=3
fi

echo "python $version is installed"

 ##########################}


if [ $(which pip2) ]; then
    PIP="pip2"
    echo "!!you are using $PIP for this installation"

else
    PIP="pip"
fi

###############################Installation process #################

 
  if [ $(which apt-get) ]; then
    echo "installing apt packages"
   # sudo apt-get update 
    sudo apt-get -y install build-essential python-dev python-pip  ##-y  Assume Yes to all queries and do not prompt
	
  elif [ $(which pacman) ]; then
    echo "installing pip"
    sudo pacman -S base-devel python2-pip
    PIP="pip2"
  elif [ $(which yum) ]; then
    sudo yum install python-pip python-devel  
  elif [ $(which zypper) ]; then
  sudo zypper install python-pip python-devel  
	
  fi
sudo -H $PIP install virtualenv # -H  set HOME variable to target user's home dir.


  ############
  
 

while true; do
  echo -n "do you like to use python virtual environment? y/n  "
  read env
  if [[ $env == "y" ]] || [[ $env == "n" ]]
  then
    printf "$env"
    break
  fi 
  echo "please type y for yes or n for no"

done


  while true; do
  echo -n "do you like to install Tensorflow for CPU or GPU? cpu/gpu  "
  read choice
  if [[ $choice == "cpu" ]] || [[ $choice == "gpu" ]]
  then
    printf " installation for $choice"
    break
  fi
    echo "please type cpu or gpu"

done
  
 
################################Normal installation##########################
if [ $env=="n" ]; 
then
echo "Install TensorFlow without python Env:"
 

 		
		if [ "$pythonV" -lt 3 ] 
			then sudo pip install --upgrade https://storage.googleapis.com/tensorflow/linux/$choice/tensorflow-0.6.0-cp27-none-linux_x86_64.whl
		    else sudo pip3 install --upgrade https://storage.googleapis.com/tensorflow/linux/$choice/tensorflow-0.6.0-cp34-none-linux_x86_64.whl
        fi
   
   
   
   
elif [ $choice =="y" ]; 
then
 virtualenv --system-site-packages ~/tensorflow
 
				if [[ "$SHELL" == *"bash"* ]]; 
					then
					source	~/tensorflow/bin/activate
					else
					source	~/tensorflow/bin/activate.csh
				fi
	
	
				if [ "$pythonV" -lt 3 ] 
				then sudo pip install --upgrade https://storage.googleapis.com/tensorflow/linux/$choice/tensorflow-0.6.0-cp27-none-linux_x86_64.whl
				else sudo pip3 install --upgrade https://storage.googleapis.com/tensorflow/linux/$choice/tensorflow-0.6.0-cp34-none-linux_x86_64.whl
				fi
 deactivate
fi


 Test_installation()
 {
cat << EOF > tensorflow_test.py
#!/usr/bin/python
  import tensorflow as tf
  hello = tf.constant('Hello, TensorFlow!')
 sess = tf.Session()
 print(sess.run(hello))

EOF
 }

source ~/tensorflow/bin/activate
echo "running test"
python tensorflow_test.py
deactivate

echo " To use TensorFlow later you will have to activate the Virtualenv environment again:"

echo " source ~/tensorflow/bin/activate  # If using bash."
echo " source ~/tensorflow/bin/activate.csh  # If using csh."
echo "(tensorflow)$  # Your prompt should change."
echo "# Run Python programs that use TensorFlow."
echo "...
echo "# When you are done using TensorFlow, deactivate the environment."
echo "(tensorflow)$ deactivate"
