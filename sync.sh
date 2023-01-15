#!/bin/bash

from=$FROM
to=$TO

content=$(curl -Ls "https://tools.hongfs.cn/v2/docker/tags/list?name=$from")

getDigest(){
    local mirror_name=$1

    local tag_manifest=$(docker manifest inspect --verbose $mirror_name 2> /dev/null)

    if [[ $tag_manifest == "" ]]; then
        echo ""
        return
    fi

    if [[ ${tag_manifest:0:1} == "{" ]]
    then
        echo $tag_manifest | jq ".Descriptor.digest"
    else
        echo $tag_manifest | jq ".[0].Descriptor.digest"
    fi
}

tags=(${content//,/ })

for i in "${!tags[@]}"
do
    tag=${tags[i]}

    from_tag="$from:$tag"
    to_tag="$to:$tag"

    echo $from_tag

    from_manifest=$(getDigest $from_tag)
    to_manifest=$(getDigest $to_tag)

    if [[ $from_manifest == "" ]];then
        continue
    fi

    if [[ $from_manifest == $to_manifest ]];then
        continue
    fi

    docker pull -q $from_tag
    docker tag $from_tag $to_tag
    docker push -q $to_tag
done
