#!/bin/bash

from=$FROM
to=$TO

content=$(curl "http://127.0.0.1:9000/get?name=$from")

echo "同步：$from -> $to"

if [[ $content == "" ]]; then
    echo "没有需要同步的镜像"
    exit 0
fi

getName() {
    local value=$1

    if [[ $value =~ "/" ]]; then
        local from_array=(${value//\// })

        echo ${from_array[-1]}
    else
        echo $value
    fi
}

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

    # if [[ $tag != "web-2" ]]; then
    #     continue
    # fi

    from_tag="$from:$tag"
    to_tag="$to:$tag"

    echo "处理：$from_tag"

    # 处理非 .aliyuncs.com 和非 ghcr.io 的镜像
    if [[ $from_tag != *.aliyuncs.com* ]] && [[ $from_tag != ghcr.io* ]]; then
        from_manifest=$(getDigest $from_tag)
        to_manifest=$(getDigest $to_tag)

        if [[ $from_manifest == "" ]];then
            echo "获取 $from_tag 的 manifest 失败"
            continue
        fi

        if [[ $from_manifest == $to_manifest ]];then
            echo "跳过：$from_tag"
            continue
        fi
    fi

    docker pull -q $from_tag
    docker tag $from_tag $to_tag
    docker push -q $to_tag
done
