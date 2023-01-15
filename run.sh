#!/bin/bash

FROM="golang" TO="registry.cn-hongkong.aliyuncs.com/hongfs/golang" ./sync.sh
FROM="golang" TO="registry.cn-shenzhen.aliyuncs.com/hongfs/golang" ./sync.sh

METERSPHERE_NAMES="test-track,system-setting,report-stat,project-management,performance-test,api-test,gateway,eureka,data-streaming,node-controller,ui-test,workstation"

for NAME in ${METERSPHERE_NAMES//,/ }; do
    FROM="registry.cn-qingdao.aliyuncs.com/metersphere/${NAME}" TO="hongfs/${NAME}" ./sync.sh
done