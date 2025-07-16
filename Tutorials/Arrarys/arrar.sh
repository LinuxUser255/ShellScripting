#!/usr/bin/env bash



machines(){
        # declare an arrary, print selected elements
        MY_LIST=(Linux Mac Windows TempleOS)
        echo ${MY_LIST[@]}; echo ${MY_LIST[3]}

        # iterate over the items in the list, echo each one and pipe it to word count
        for item in ${MY_LIST[@]}; do echo -h $item | wc -c; done
}


