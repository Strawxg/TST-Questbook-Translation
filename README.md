TST 任务书

使用 DeepSeek 机翻版本，目前由Straw完成第二次人工校对，目前已去除绝大部分的格式错误、机翻内容和少部分的赘余描述。你可以 fork 这个仓库，创建自己的翻译，或者提交你觉得有问题的翻译，以及提交更好的翻译方式来完善翻译，目前该版本已适配至GTNH版本2.7.4

使用方法

将仓库中的 zh_CH.lang 内容复制到./config/txloader/load/betterquesting/lang/zh_CN.lang 文件末尾，即在原GTNH翻译lang文件末尾添加TST任务书的翻译，然后重启游戏即可，如果翻译未变化，可以输入 `/bq_admin default load` 重新加载任务书

建议使用 `VSCode `进行此项操作，以避免出现格式错误问题

# Twist-Stuff

My Twist Space Repo - QBs &amp; Info

Instructions for how to download the Twist Questbook using the Easy Way:

The DefaultQuests is the entire QuestBook from GTNH, including a chapter on Twist that I made.

To add it to your pack:

First, click the blue `<> CODE` button and download the ZIP

1. Go to configs
2. Navigate to the betterquesting folder
3. DELETE the "DefaultQuests" folder.
4. Download the "DefaultQuests" Folder that exists on this repository
5. Copy it to the betterquesting folder; this will add the Twist Quest Page
6. Go in-game and type the command `/bq_admin default load` (YOU DO NOT NEED OP FOR THIS), this will load the questbook with all the Twist Quests added. Because quests are saved world side, you will not lose any progress with your current quests, but please contact Aditya if you run into any troubles

To install it the Hard Way (manually, not recommended):

1. Download all the folders separately so as not to get confused, including the QuestLinesOrder.txt
2. Copy the Twist Space Technology Folder in the QuestLines folder from this repository to the `QuestLines` folder in the `DefaultQuests` Folder.
3. Copy the Twist Space Technology Folder in the Quests folder from this repository to the `Quests` folder in the `DefaultQuests` Folder.
4. Replace the `QuestLinesOrder.txt` in your INSTANCE folder with the one you downloaded from this repository.

Reload the QuestBook after using the default load command. This should work, but please don't hesitate to contact me in my Discord or the Twist Discord if you have any questions.

以下为安装方法的翻译版本，仅提供简单方法的译文，为保证其他中文翻译不被覆盖  

建议在安装完成后，重新按照中文wiki的安装翻译的方法安装翻译，由于Betterquesting模组的特性，这不会导致TST的任务被覆盖  

1.找到你安装GTNH的文件夹，找到.minecraft/configs/betterquesting  

2.删除Defaultquests文件夹，下载本库所提供的Defaultquests文件夹  

3.将其复制到原来的betterquesting文件夹  

4.输入指令：`/bq_admin default load`，若你为服务器管理员，此步骤可跳过。  


简单安装方法因GTNH 2.8.0后BQ任务架构变动，导致无法安装，故已被弃置
请按照以下方法安装任务书，并添加翻译
(1)下载任务书，请在Github上选择code→Download ZIP，以下载全部的任务及其汉化文件
(2)找到你的GTNH安装根目录，找到.minecraft/config/betterquesting/DefaultQuests
(3)将下载好的压缩包进行解压，将Quest and Stuff中所有内容复制到DefaultQuests目录下
(4)由于任务架构改动，您大概率无法在安装完成后看到TST的任务，请使用/bq_admin default load进行任务重载
(5)汉化文件为zh_CN.lang文件，若您无法区分，可以进行重命名（后续将依旧按照默认文件名进行讲解），但请保留.lang文件格式,同时请找到游戏的.minecraft/config/txloader/load/betterquesting/lang/下的zh_CN.lang
(6)将压缩包中的zh_CN.lang文件打开，使用Ctrl+A全选，使用Ctrl+C复制，并打开.minecraft/config/txloader/load/betterquesting/lang/下的zh_CN.lang文件
(7)将复制的内容粘贴到.minecraft/config/txloader/load/betterquesting/lang/下的zh_CN.lang 文本下面，使用Ctrl+S保存。 即：以上内容是将zip中的新增任务汉化，追加到原GTNH的任务汉化，以实现新增TST任务及其汉化
(8)进入游戏，选择中文语言即可看到翻译，若存在部分format error属正常现象（可能是XSana的提取脚本导致的，但不影响任务本身），若您有方法解决此类问题，可以提交pull request或issues。

Node.js下可以通过gen_quest.js文件尝试提取，用Deepseek写的，需要放在实例目录下才可以提取任务文本，该脚本可能有问题，欢迎提交PR修改可能出现的bug。 用法如下：

node gen_quests.js 交互式：列出章节并选择
node gen_quests.js list 只列出所有任务章节
node gen_quests.js "Feeding Yourself" 按章节名称提取（推荐）
node gen_quests.js AAAAAAAAAAAAAAAAAAAACg 复制TST任务编号，按任务代码提取
node gen_quests.js 10 按列表序号提取

2026.11.14更新：
为简化下载，后续汉化将开启release发行。并删除所有分支，合并为同一分支，并命名为2.9.0
上传2.9.0人工汉化翻译。

## Star History

<a href="https://www.star-history.com/?repos=strawxg%2Ftst-questbook-translation&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=strawxg/tst-questbook-translation&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=strawxg/tst-questbook-translation&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=strawxg/tst-questbook-translation&type=date&legend=top-left" />
 </picture>
</a>