#!/usr/bin/csh

#Copyright 2019-2021 T-Head Semiconductor Co., Ltd.
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

setenv ToolChainPathAdd /data/tools/gcc/t-head/Xuantie-900-gcc-elf-newlib-x86_64-V2.6.1/bin

if (! $?TOOL_EXTENSION) then
  echo 'setenv TOOL_EXTENSION path: $(ToolChainPath)'
  #setenv TOOL_EXTENSION /data/tools/gcc/t-head/Xuantie-900-gcc-elf-newlib-x86_64-V2.6.1/bin
  setenv TOOL_EXTENSION ${ToolChainPathAdd}
else
  if ("${TOOL_EXTENSION}" == "") then
    echo "[Info] Current TOOL_EXTENSION is empty, update it"
    setenv TOOL_EXTENSION ${ToolChainPathAdd}
  else
    setenv TOOL_EXTENSION ${ToolChainPathAdd}:${TOOL_EXTENSION}
  endif
endif

echo 'Final Toolchain path :'
echo "    ${TOOL_EXTENSION}"
