#! /bin/bash
#
# beigesteuert von maschmakai

TOTALROUTER=$1
TOTALROWS=$2
ROUTER=$3
INTERFACE=$4
PROVIDER=$5

RPR=$[${TOTALROUTER}/${TOTALROWS}] #get routers per row

if [ "$((ROUTER%RPR))" == "0" ]
then
    ROW=$[${ROUTER}/${RPR}]
else
    ROW=$[${ROUTER}/${RPR}+1]
fi

FIRSTROUTER=$[$[${ROW}*${RPR}]-$[${RPR}-1]]
LASTROUTER=$[${ROW}*${RPR}]


case $INTERFACE in
    1)
	if [ "$ROUTER" == "$FIRSTROUTER" ]
        then
	    echo "${PROVIDER}0${ROUTER}${INTERFACE}"
            #echo "$((ROUTER+100))"
        else
            echo "${PROVIDER}$((ROUTER-1))$ROUTER"
        fi
	;;

    2)
	if [ "$ROW" == "1" ]
	then
	    echo "${PROVIDER}0${ROUTER}${INTERFACE}"
	    #echo "$((ROUTER+200))"
	else
	    echo "${PROVIDER}$((ROUTER-RPR))$ROUTER"
	fi
	;;

    3)
	if [ "$ROUTER" == "$LASTROUTER" ]
        then
	    echo "${PROVIDER}0${ROUTER}${INTERFACE}"
            #echo "$((ROUTER+300))"
        else
            echo "${PROVIDER}$ROUTER$((ROUTER+1))"
        fi
	;;

    4)
	if [ "$ROW" == "$TOTALROWS" ]
        then
	    echo "${PROVIDER}0${ROUTER}${INTERFACE}"
            #echo "$((ROUTER+400))"
        else
            echo "${PROVIDER}$ROUTER$((ROUTER+RPR))"
        fi
	;;
esac

