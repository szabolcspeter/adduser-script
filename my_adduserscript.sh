#!/bin/bash

COMMENT=""
SHELL=/bin/bash
USERNAME=""
GROUP=tsystems
SKELETON=/etc/skel
NO_HOME=n

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

if [ $# -eq 0 -o $# -gt 10 ]; then
  echo 
  echo "Usage: $( basename $0 ) [OPTIONS] <user name>"
  echo "OPTIONS:"
  echo "   -c, --comment USER_REAL_NAME"
  echo "   -s, --shell   USED_SHELL"
  echo "   -g, --gid	 GROUP_NAME"
  echo "   -k, --skel    SKELETON_DIRECTORY"
  echo "   -M, --no-home"
  echo "       This means you do not want to create user's home directory."
  echo
  exit 1 
fi

while [ $# -gt 0 ]
do
  case "$1" in
      -c | --comment)
                     if [ -z "$2" -o "$( echo "$2" | cut -c 1 )" = "-" ]; then
                       echo "Comment is missing."
                       exit 2
                     fi
                     COMMENT=$2
		     shift 2
		     ;;

        -s | --shell)
                     if [ -z "$2" -o "$( echo "$2" | cut -c 1 )" = "-" ]; then
                       echo "Shell is missing."
                       exit 2
                     fi
                     SHELL=$2
                     shift 2
                     ;;

          -g | --gid)
                     if [ -z "$2" -o "$( echo "$2" | cut -c 1 )" = "-" ]; then
                       echo "Group is missing."
                       exit 2
                     fi
                     GROUP=$2
                     shift 2
                     ;;

         -k | --skel)
                     if [ -z "$2" -o "$( echo "$2" | cut -c 1 )" = "-" ]; then
                       echo "Skeleton directory is missing."
                       exit 2
                     fi
                     SKELETON=$2
                     shift 2
                     ;;

      -M | --no-home)
                     NO_HOME=y
                     shift 1
                     ;;

                  --)
                     if [ $# -ne 2 ]; then
                       echo "Username is missing or too many parameters."
                       exit 2
                     fi
                     USERNAME=$2
                     shift 2
                     ;;

                   *)
                     if [ $# -eq 1 -a "$( echo "$1" | cut -c 1 )" != "-" ]; then
                       USERNAME=$1
                       shift 1
                     else
                       echo "Invalid option $1"
                       exit 2 
                     fi
                     ;;
  esac
done

if [ -z "$USERNAME" ]; then
  echo "Username is missing."
  exit 2
fi

echo
echo "Username: $USERNAME"
echo "Comment:  $COMMENT"
echo "Shell:    $SHELL"
echo "Group:    $GROUP"
echo "Skeleton  $SKELETON"
echo "No home:  $NO_HOME"
echo

until [ -n "$answer" ] 
do
  echo -n "Is that right? "
  read question
  case "$question" in  
      y | Y | yes | YES)
                        answer="ok"
                        ;;

     "kapd be a pocsom")
                        echo "Vegre valaki megnezte a forraskodot is! Helyes :-)"
                        echo "Most kilepek, mert ilyen csunyakat irkalsz nekem."
                        exit 3
                        ;;

        n | N | no | NO)
                        exit 3
                        ;;

                       *)
                         echo "possible answers: y/Y | yes/YES | n/N | no/NO"
                         ;; 
  esac
done

OLD=$( cat /etc/passwd | grep "$USERNAME" | wc -l )
if [ $OLD -gt 0 ]; then
  echo "Account '$USERNAME' already exists. I'm doing nothing."
  exit 4
else
  COMMAND="/usr/sbin/useradd "
  if [ -n "$COMMENT" ]; then
    COMMAND="$COMMAND -c \"$COMMENT\""
  fi
  if [ "$NO_HOME" = "y" ]; then
    COMMAND="$COMMAND -M"
  else
    COMMAND="$COMMAND -m -k $SKELETON"
  fi    
  COMMAND="$COMMAND -g $GROUP -s $SHELL $USERNAME"
fi

eval $COMMAND
/bin/echo -e "start123#" | (/usr/bin/passwd --stdin $USERNAME)  

exit 0


