#!/bin/sh

args=("$#")
help_file="help.txt"

if [ -e "$1" ]
then
    touch ./file.sh
    cp "$1" "file.sh"
    file="file.sh"
    donum=`grep -n "do " "file.sh"`
    thennum=`grep -n "then" "file.sh"`
    ifnum=`grep -n "if" "file.sh"`
    semicolonnum=`grep -n ";" "file.sh"`
    thenstr=`grep "then" "file.sh"`
    ifstr=`grep "if" "file.sh"`
    dostr=`grep "do" "file.sh"`
    semicolonstr=`grep ";" "file.sh"`
    thenlen=-1
    thn=-1
    dolen=-1
    dn=-1
    ifn=-1
    iflen=-1
    semicolon_character=-1
    filename="no filename"
    s=$( get_comment $file)
    openbracketstr=`grep "{" "file.sh"`
    openbracketnum=`grep -n "{" "file.sh"`
    closebracketnum=`grep -n "}" "file.sh"`
    closebracketstr=`grep "}" "file.sh"`
fi

find_number()
{
    thenstr=`grep "then" "$file"`
    thennum=`grep -n "then" "$file"`
    t="$thennum"
    len=${#t}
    i=0
    num=-1

    while [ $len -gt $i ]
    do
        if [ "${t:$i:1}" = ":" ]
        then
            num="$i"
        fi
        i=$(( $i + 1 ))
    done
    echo "$num"
}

find_number_openbracket()
{
    openbracketstr=`grep "{" "$file"`
    openbracketnum=`grep -n "{" "$file"`
    t="$openbracketnum"
    len=${#t}
    i=0
    num=-1

    while [ $len -gt $i ]
    do
        if [ "${t:$i:1}" = ":" ]
        then
            num="$i"
        fi
        i=$(( $i + 1 ))
    done
    echo "$num"
}

find_number_closebracket()
{
    closebracketstr=`grep "}" "$file"`
    closebracketnum=`grep -n "}" "$file"`
    t="$closebracketnum"
    len=${#t}
    i=0
    num=-1

    while [ $len -gt $i ]
    do
        if [ "${t:$i:1}" = ":" ]
        then
            num="$i"
        fi
        i=$(( $i + 1 ))
    done
    echo "$num"
}

find_position_of_openbracket()
{
    openbracketstr=`grep "{" "$file"`
    openbracketnum=`grep -n "{" "$file"`
    
    t="$openbracketstr"
    len=${#t}
    i=0
    num=-1

    while [ $len -gt $i ]
    do
        if [ "${t:$i:1}" = "{" ]
        then
            num="$i"
        fi
        i=$(( $i + 1 ))
    done
    echo "$num"
}

find_position_of_closebracket()
{
    closebracketstr=`grep "}" "$file"`
    closebracketnum=`grep -n "}" "$file"`
    
    t="$closebracketstr"
    len=${#t}
    i=0
    num=-1

    while [ $len -gt $i ]
    do
        if [ "${t:$i:1}" = "}" ]
        then
            num="$i"
        fi
        i=$(( $i + 1 ))
    done
    echo "$num"
}

check_for_openbracket()
{
    openbracketstr=`grep "{" "$file"`
    openbracketnum=`grep -n "{" "$file"`
    
    FC=${openbracketstr:0:1}
    obposition=$( find_position_of_openbracket $openbracketstr )
    len=${#openbracketstr}
    obnum=$( find_number_openbracket $openbracketnum )
    ob=${openbracketnum:0:$obnum}
    characterbeforebracket=""
    off=""
    obnn=0
    if [ $obposition == "0" ]
    then
        sed -i 's/{/{\n/g' "$file"
    else
        off=$(( obposition - 1 ))
        blla=${openbracketstr:$off:$len}
        obnn=$(( $ob + 1 ))
        sed -i 's/{/\n{\n/g' "$file"
    fi
}

brackets_not_in_the_same_line()
{
    openbracketstr=`grep "{" "$file"`
    openbracketnum=`grep -n "{" "$file"`
    closebracketstr=`grep "}" "$file"`
    closebracketnum=`grep -n "}" "$file"`   
    FCO=${openbracketstr:0:1}
    obposition=$( find_position_of_openbracket $openbracketstr )
    openlen=${#openbracketstr}
    obnum=$( find_number_openbracket $openbracketnum )
    ob=${openbracketnum:0:$obnum}
    off=""
    obnn=0
    FCC=${closebracketstr:0:1}
    cbposition=$( find_position_of_closebracket $closebracketstr )
    closelen=${#closebracketstr}
    cbnum=$( find_number_closebracket $closebracketnum )
    cb=${closebracketnum:0:$cbnum}
    cff=""
    cbnn=0

    if [ $FCO == "{" -a $openlen == 1 ]
    then
        :
    else
        off=$(( obposition - 1 ))
        blla=${openbracketstr:$off:$openlen}
        obnn=$(( $ob + 1 ))
        sed -i 's/{/\n{\n/g' "$file"
    fi
    
    empty=$(( $cb + 1 ))
    FIRSTLINECLOSE=`sed "${empty}q;d" "$file"`
    if [ $FCC == "}" -a $closelen == 1 ]
    then
        if [ -z "$FIRSTLINECLOSE" ]
        then
            :
        else
            sed -i 's/}/}\n/g' "$file"
        fi
    else
        cff=$(( cbposition - 1 ))
        bllaclose=${closebracketstr:$cbposition:$closelen}
        cbnn=$(( $cb + 1 ))
        sed -i 's/}/\n}\n/g' "$file"
    fi
}

check_if_brackets_are_in_same_line()
{
    openbracketstr=`grep "{" "$file"`
    openbracketnum=`grep -n "{" "$file"`
    obnum=$( find_number_openbracket $openbracketnum )
    cbnum=$( find_number_closebracket $closebracketnum )
    ob=${openbracketnum:0:$obnum}
    cb=${closebracketnum:0:$cbnum}

    if [[ $ob == $cb ]]
    then
        check_for_openbracket
        sed -i 's/}/\n}\n/g' "$file"
    else
        brackets_not_in_the_same_line
    fi
}

fix_brackets()
{
    if [ "$openbracketstr" != "" -a "$closebracketstr" != "" ]
    then
        check_if_brackets_are_in_same_line
    else
        :
    fi
}

check_beginning_of_then()
{
    thenstr=`grep "then" "file.sh"`
    thennum=`grep -n "then" "file.sh"`
    number=$( find_number $thennum )
    thn=${thennum:0:$number}
    FC=${thenstr:0:4}
    len=${#thenstr}

    if [ "$FC" == "then" ]
    then
        :
    else
        sed -i "${thn}d" "file.sh"
        sed -i "${thn}i\then" "file.sh"
    fi
}

check_beginning_of_then_no_newline()
{
    thenstr=`grep "then" "file.sh"`
    thennum=`grep -n "then" "file.sh"`
    number=$( find_number $thennum )
    thn=${thennum:0:$number}
    FC=${thenstr:0:4}
    len=${#thenstr}

    if [ "$FC" == "then" ]
    then
        :
    else
        sed -i "${thn}d" "file.sh"
        sed -i "${thn}i\then" "file.sh"
    fi
}

check_after_then()
{
    thenstr=`grep "then" "$file"`
    thennum=`grep -n "then" "$file"`
    number=$( find_number $thennum )
    thn=${thennum:0:$number}
    len=${#thenstr}
    i=0
    
    while [ $len -gt $i ]
    do
        j=$(( $i + 1 ))
        k=$(( $i + 2 ))
        l=$(( $i + 3 ))
        m=$(( $i + 4 ))
        n=$(( $i + 5 ))
        if [ \( "${thenstr:$i:1}" = "t" -a "${thenstr:$j:1}" = "h" -a "${thenstr:$k:1}" = "e" -a "${thenstr:$l:1}" = "n" -a  "${thenstr:$m:1}" = " " \) ]
        then
            blla=${thenstr:$n:$len}
            thnn=$(( $thn + 1 ))
            sed -i "${thnn}i\\$blla" "$file"
            check_beginning_of_then
        else
            :
        fi
        i=$(( $i + 1 ))
    done
}

find_semicolon()
{
    t="$semicolonstr"
    len=${#t}
    i=0
    
    while [ $len -gt $i ]
    do
        if [[ "${t:$i:1}" = ";" ]]
        then
            semicolon_character="$i"
        fi
        i=$(( $i + 1 ))
    done
    echo "$semicolon_character"
}

split_do_then()
{
    input="$file"
    if [ "$thenstr" != "" ]
    then
        thenlen=${#thenstr}
        number=$( find_number $thennum )
        thn=${thennum:0:$number}
        if [ "$dostr" != "" ]
        then
            dolen=${#dostr}
            donumber=$( find_number $donum )
            dn=${donum:0:$donumber}
            if [ $dn == $thn ]
            then
                len=${#thenstr}
                i=0
                while [ $len -gt $i ]
                do
                    j=$(( $i + 1 ))
                    k=$(( $i + 2 ))
                    l=$(( $i + 3 ))
                    m=$(( $i + 4 ))
                    if [ \( "${thenstr:$i:1}" = "t" -a "${thenstr:$j:1}" = "h" -a "${thenstr:$k:1}" = "e" -a "${thenstr:$l:1}" = "n" \) ]
                    then
                        if [[ "${thenstr:$m:1}" = "$newline" ]]
                        then
                            sed -i 's/;/\n/g' "$input"
                            check_beginning_of_then
                        else
                            sed -i 's/;/\n/g' "$input"
                            check_after_then
                        fi
                    fi
                    i=$(( $i + 1 ))
                done
            else
                :
            fi
        fi
        if [ "$ifstr" != "" ]
        then
            iflen=${#ifstr}
            ifnumber=$( find_number $ifnum )
            ifn=${ifnum:0:$ifnumber}
            if [ $ifn == $thn ]
            then
                len=${#thenstr}
                i=0
                while [ $len -gt $i ]
                do
                    j=$(( $i + 1 ))
                    k=$(( $i + 2 ))
                    l=$(( $i + 3 ))
                    m=$(( $i + 4 ))
                    if [ \( "${thenstr:$i:1}" = "t" -a "${thenstr:$j:1}" = "h" -a "${thenstr:$k:1}" = "e" -a "${thenstr:$l:1}" = "n" \) ]
                    then
                        if [[ "${thenstr:$m:1}" = "$newline" ]]
                        then
                            sed -i 's/;/\n/g' "$input"
                            check_beginning_of_then
                        else
                            sed -i 's/;/\n/g' "$input"
                            check_after_then
                        fi
                    fi
                    i=$(( $i + 1 ))
                done
            else
                :
            fi
        fi
    fi
}

do_then()
{
    input="$file"
    f=$(get_filename)
#    s=$(get_comment $input)
    FIRSTLINE=`head -n 1 $input`
    SECONDLINE=`head -2 $input | tail -1`
    if [ "$FIRSTLINE" != "#!/bin/sh" ]
    then
        if [ -z "$FIRSTLINE" ]
        then
            if [ -z "$SECONDLINE" ]
            then
                sed -i "1i\#!/bin/sh" "$input"
                sed -i "2d" "$input"
                split_do_then $input
            else
                sed -i "1i\#!/bin/sh" "$input"
                split_do_then $input
            fi
        else
            if [ -z "$SECONDLINE" ]
            then
                sed -i "1i\#!/bin/sh\n" "$input"
                sed -i "2d" "$input"
                split_do_then $input
            else
                sed  -i "1i\#!/bin/sh\n" "$input"
                split_do_then $input
            fi
        fi
    else
        if [ ! -z "$SECONDLINE" ]
        then
            split_do_then $input
            sed -i "1G" "$input"
        else
            split_do_then $input
        fi
    fi
}


check_day()
{
    day=$(date "+%-d")
    
    case "$day" in
        1 | 21 | 31 )
            echo "st"
            ;;
        2 | 22 )
            echo "nd"
            ;;
        3 )
            echo "rd"
            ;;
        * )
            echo "th"
            ;;
    esac
}

d=$(date "+%-d`check_day` %B, %Y")

no_arguments()
{
    echo "Program must take more than one argument!"
    exit 84
}

shebang_missing()
{
    t="$file"
    FIRSTLINE=`head -n 1 $t`
    SECONDLINE=`head -2 $t | tail -1`
    if [ -z "$FIRSTLINE" ]
    then
        if [ -z "$SECONDLINE" ]
        then
            fix_brackets
            sed -i "1i\#!/bin/sh" "$t"
            sed -i "2d" "$t"
        else
            fix_brackets
            sed -i "1i\#!/bin/sh" "$t"
        fi
    else
        if [ -z "$SECONDLINE" ]
        then
            fix_brackets
            sed -i "1i\#!/bin/sh\n" "$t"
            sed -i "2d" "$t"
        else
            fix_brackets
            sed -i "1i\#!/bin/sh\n" "$t"
        fi
    fi
}

check_if_shebang()
{
    t="$file"
    FIRSTLINE=`head -n 1 $t`
    SECONDLINE=`head -2 $t | tail -1`
    if [ "$FIRSTLINE" != "#!/bin/sh" ]
    then
        shebang_missing $t
    else
        if [ ! -z "$SECONDLINE" ]
        then
            fix_brackets
            sed -i "1G" "$t"
        else
            fix_brackets
        fi
    fi
}

help()
{
    while IFS= read -r line
    do
        echo "$line"
    done < "$help_file"
}

get_comment()
{
    t="$file"
    comment=""
    while IFS= read -r line
    do
        if [[ "$line" == "#"* ]]
        then
            comment=$line
        fi
    done < "$t"
    echo "$comment"
}

check_other_option()
{
    t="$1"
    if [ $t == "-help" ]
    then
        help
    else
        echo "$t does not exist."
        exit 84
    fi
}

check_if_file()
{
    t="$file"
    FIRSTLINE=`head -n 1 $t`
    TC=${FIRSTLINE:0:2}
    if [ "$TC" != "#!" ]
    then
        sed -i '1i\#!/bin/sh\n' $t
    else
        :
    fi
}

default_cases()
{
    t="$file"
    i=`(grep "if" $t & grep "do" $t ) | grep -n "then"`

    if [ `grep "if" $t | grep "then"` ]
    then
        echo "in the same line"
    else
        echo "not in the same line"
    fi
}

one_argument()
{
    t="$file"
    if [ -e "$t" ]
    then
        check_if_shebang "$t"
        while IFS= read -r line
        do
            echo -e "\e[34m $line"
        done < "./file.sh"
        rm -f ./file.sh
    else
        check_other_option "$1"
    fi
}

if [ "$#" == 0 ]
then
    no_arguments
elif [ "$#" == 1 ]
then
    one_argument $1
else
    SHORT=hi:seo:
    LONG=header,indentation:,spaces,expand,output:,out:,help
    
    nb_arg=8
    
    if ! OPTS=$(getopt --options $SHORT --long $LONG -- "$@")
    then
        help
        exit 84
    fi
    
ARGUMENT_LIST=(
    "indentation"
    "output"
)
    
header()
{
    s=$( get_comment $input)
    input="$file"
    FIRSTLINE=`head -n 1 $input`
    SECONDLINE=`head -2 $input | tail -1`
    if [ "$FIRSTLINE" != "#!/bin/sh" ]
    then
        if [ -z "$FIRSTLINE" ]
        then
            if [ -z "$SECONDLINE" ]
            then
                sed -i "1i\#!/bin/sh" "$input"
                sed -i "2d" "$input"
                sed -i "3i\#####################\n#\n#\n# ${filename} \n# \\$d \n#\n# ${s}\n#####################\n" "$input"
            else
                sed -i "1i\#!/bin/sh" "$input"
                sed -i "1i\#####################\n#\n#\n# ${filename} \n# \\$d \n#\n# ${s}\n#####################\n" "$input"
            fi
        else
            if [ -z "$SECONDLINE" ]
            then
                sed -i "1i\#!/bin/sh\n" "$input"
                sed -i "2d" "$input"
                sed -i "2i\#####################\n#\n#\n# ${filename} \n# \\$d \n#\n# ${s}\n#####################\n" "$input"
            else
                sed  -i "1i\#!/bin/sh\n" "$input"
                sed -i "3i\#####################\n#\n#\n# ${filename} \n# \\$d \n#\n# ${s}\n#####################\n" "$input"
            fi
        fi
    else
        if [ ! -z "$SECONDLINE" ]
        then
            sed -i "1G" "$input"
            sed -i "2i\#####################\n#\n#\n# ${filename} \n# \\$d \n#\n# ${s}\n#####################\n" "$input"
        else
            sed -i "2i\#####################\n#\n#\n# ${filename} \n# \\$d \n#\n# ${s}\n#####################\n" "$input"
        fi
    fi
}

input="$file"
eval set -- "$OPTS"
while true ;
do
    case "$1" in
        -h | --header )
            fix_brackets
            header $input
            shift
            ;;
        -s | --spaces )
            echo "-s option"
            shift
            ;;
        -i | --indentation )
            nb_char=$2
            echo "-i option $2"
            shift 2
            ;;
        -e | --expand )
            do_then $input
            shift
            ;;
        -o | --output | --out )
            filename="$2"
            shift 2
            ;;
        * | --)
            break
            ;;
    esac
done
while IFS= read -r line
do
    echo -e "\e[34m $line"
done < "./file.sh"

rm -f ./file.sh
fi
