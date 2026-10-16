TST任务书  
目前由Straw完成第四次人工翻译  
你可以 fork 这个仓库，创建自己的翻译，或者提交你觉得有问题的翻译，以及提交更好的翻译方式来完善翻译，目前2.8.0分支已适配至GTNH版本2.8.4，TST版本0.7.7。  

Node.js下可以通过gen_quest.js文件尝试提取，用ds写的，可能有问题，欢迎提交PR修改可能出现的bug。
用法如下：
 *   node gen_quests.js                         交互式：列出章节并选择
 *   node gen_quests.js list                    只列出所有任务章节
 *   node gen_quests.js "Feeding Yourself"      按章节名称提取（推荐）
 *   node gen_quests.js AAAAAAAAAAAAAAAAAAAACg  复制TST任务编号，按任务代码提取
 *   node gen_quests.js 10                      按列表序号提取


安装任务书方法：  
简单安装方法因GTNH 2.8.0后任务架构变动，导致无法安装，故已被弃置  
请按照以下方法安装任务书，并添加翻译  
(1)下载任务书，请在Github上选择code→Download ZIP，以下载全部的任务及其汉化文件  
(2)找到你的GTNH安装根目录，找到.minecraft/config/betterquesting/DefaultQuests  
(3)将下载好的压缩包进行解压，将`Quest and Stuff`中所有内容复制到`DefaultQuests`目录下  
(4)由于任务架构改动，您大概率无法在安装完成后看到TST的任务，请使用`/bq_admin default load`进行任务重载  
(5)汉化文件为`zh_CN.lang`文件，若您无法区分，可以进行重命名（后续将依旧按照默认文件名进行讲解），但请保留`.lang`文件格式,同时请找到游戏的`.minecraft/config/txloader/load/betterquesting/lang/`下的`zh_CN.lang`  
(6)将压缩包中的zh_CN.lang文件打开，使用Ctrl+A全选，使用Ctrl+C复制，并打开`.minecraft/config/txloader/load/betterquesting/lang/`下的zh_CN.lang文件  
(7)将复制的内容粘贴到`.minecraft/config/txloader/load/betterquesting/lang/`下的`zh_CN.lang` 文本下面，使用Ctrl+S保存。  即：以上内容是将zip中的新增任务汉化，追加到原GTNH的任务汉化，以实现新增TST任务及其汉化  
(8)进入游戏，选择中文语言即可看到翻译，若存在部分format error属正常现象（可能是XSana的提取脚本导致的，但不影响任务本身），若您有方法解决此类问题，可以提交pull request或issues。


## Star History

<a href="https://www.star-history.com/?repos=strawxg%2Ftst-questbook-translation&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=strawxg/tst-questbook-translation&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=strawxg/tst-questbook-translation&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=strawxg/tst-questbook-translation&type=date&legend=top-left" />
 </picture>
</a>