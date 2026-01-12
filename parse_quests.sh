#!/bin/bash

output="quests_output.txt"
fixed_id="_-aiEKuQSJy_zPlDW08sDA"
> "$output"

find "./Quests and Stuff/Quests" -type f -name "*.json" | while read -r file; do
  name=$(jq -r '.["properties:10"]["betterquesting:10"]["name:8"]' "$file")
  desc=$(jq -r --raw-output '.["properties:10"]["betterquesting:10"]["desc:8"] | gsub("\n"; "%n")' "$file")

  {
    echo "# Quest: $name"
    echo "betterquesting.quest.$fixed_id.name=$name"
    echo "betterquesting.quest.$fixed_id.desc=$desc"
    echo ""
  } >> "$output"
done

echo "✅ 所有任务已写入到 $output，换行已在提取阶段转为 %n"
