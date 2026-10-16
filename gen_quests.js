#!/usr/bin/env node
'use strict';
/*
 * gen_quests.js — GTNH BetterQuesting 任务提取脚本（Node.js 版）
 *
 * 把这个脚本放到整合包主目录（包含 config 文件夹的那一级，例如
 * `.minecraft/versions/GTNH 2.9.0-RC-2/`）下，然后运行：
 *
 *   node gen_quests.js                      交互式：列出章节并选择
 *   node gen_quests.js list                 只列出所有任务章节
 *   node gen_quests.js "Feeding Yourself"   按章节名称提取
 *   node gen_quests.js AAAAAAAAAAAAAAAAAAAACg  按任务代码提取
 *   node gen_quests.js 10                   按列表序号提取
 *
 * 可选参数：
 *   --base PATH   整合包主目录（默认脚本所在目录）
 *   --out  PATH   输出文件路径（默认 <章节名>.txt）
 * 也可用环境变量 BQ_BASE / BQ_OUT 覆盖。
 *
 * 输出格式与示例脚本一致：每个子任务输出
 *   # Quest: <名称>
 *   betterquesting.quest.<任务代码>.name=<名称>
 *   betterquesting.quest.<任务代码>.desc=<描述>
 * 换行在提取阶段已转为 %n，字面 % 已转义为 %%，与 zh_CN.lang 规则一致。
 * 成品翻译由人工完成。
 */

const fs = require('fs');
const path = require('path');
const readline = require('readline');

// ---------- 参数解析 ----------
const args = process.argv.slice(2);
let baseArg = null;
let outArg = null;
const positional = [];
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--base' && args[i + 1]) { baseArg = args[++i]; }
  else if (args[i] === '--out' && args[i + 1]) { outArg = args[++i]; }
  else { positional.push(args[i]); }
}

const base = path.resolve(baseArg || process.env.BQ_BASE || __dirname).replace(/[\\/]+$/, '');
const outOverride = outArg || process.env.BQ_OUT || null;
const queryArg = positional.length ? positional[0] : null;

const bqRoot = path.join(base, 'config', 'betterquesting', 'DefaultQuests');
const qlDir = path.join(bqRoot, 'QuestLines');
const qDir = path.join(bqRoot, 'Quests');

// ---------- 工具函数 ----------
function readJson(p) {
  let raw = fs.readFileSync(p, 'utf8');
  if (raw.charCodeAt(0) === 0xFEFF) raw = raw.slice(1); // 去掉 BOM
  return JSON.parse(raw);
}

function bqProps(p) {
  const obj = readJson(p);
  const props = obj['properties:10'];
  if (!props) return null;
  return props['betterquesting:10'] || null;
}

// JSON 原文 -> .lang 值：先转义 %，再把换行转 %n
function toLangValue(s) {
  if (s == null) return '';
  s = String(s).replace(/\r\n/g, '\n').replace(/\r/g, '\n');
  s = s.replace(/%/g, '%%');
  s = s.replace(/\n/g, '%n');
  return s;
}

// 去掉 Minecraft 颜色/格式码（§ + 单个字符），得到纯文本名称
function stripFormat(s) {
  if (s == null) return '';
  return String(s).replace(/\u00a7./g, '').replace(/\u00a7/g, '');
}

// 目录名/文件名形如 <Name>-<24位代码>，代码永远是最后 24 个字符（22 + '=='）
function codeFromName(name) {
  return name.slice(-24).replace(/=+$/, '');
}

// ---------- 读取 ----------
function listQuestLines() {
  if (!fs.existsSync(qlDir)) return [];
  const dirs = fs.readdirSync(qlDir).filter(d => d.endsWith('=='));
  return dirs.map(d => {
    const code = codeFromName(d);
    let name = code;
    let desc = '';
    const qlj = path.join(qlDir, d, 'QuestLine.json');
    if (fs.existsSync(qlj)) {
      try {
        const p = bqProps(qlj);
        if (p) {
          name = p['name:8'] || code;
          desc = p['desc:8'] || '';
        }
      } catch (e) { /* 忽略单个坏文件 */ }
    }
    return { name, desc, code, dirName: d };
  }).sort((a, b) => (a.code < b.code ? -1 : a.code > b.code ? 1 : 0));
}

function extractQuests(questDir) {
  const files = fs.readdirSync(questDir).filter(f => f.endsWith('.json'));
  return files.map(f => {
    const code = codeFromName(f.slice(0, -5)); // 去掉 .json
    let name = '';
    let desc = '';
    try {
      const p = bqProps(path.join(questDir, f));
      if (p) {
        name = p['name:8'] || '';
        desc = p['desc:8'] || '';
      }
    } catch (e) {
      console.error('[警告] 无法解析 ' + f + '：' + e.message);
    }
    return { name, desc, code };
  }).sort((a, b) => (a.code < b.code ? -1 : a.code > b.code ? 1 : 0));
}

// ---------- 输出 ----------
function buildOutput(quests) {
  const lines = [];
  for (const q of quests) {
    lines.push('# Quest: ' + stripFormat(q.name));
    lines.push('betterquesting.quest.' + q.code + '.name=' + toLangValue(q.name));
    lines.push('betterquesting.quest.' + q.code + '.desc=' + toLangValue(q.desc));
    lines.push('');
  }
  while (lines.length && lines[lines.length - 1] === '') lines.pop();
  return lines.join('\n') + '\n';
}

function printList(questlines) {
  console.log('共 ' + questlines.length + ' 个任务章节：');
  questlines.forEach((ql, i) => {
    console.log('  [' + String(i + 1).padStart(2, ' ') + '] ' + ql.name + '  (' + ql.code + ')');
  });
}

function prompt(question) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  return new Promise(resolve => {
    rl.question(question, ans => { rl.close(); resolve(ans); });
  });
}

// ---------- 主流程 ----------
async function main() {
  if (!fs.existsSync(bqRoot)) {
    console.error('[错误] 找不到目录：' + bqRoot);
    console.error('请把脚本放到整合包主目录下运行，或用 --base / 环境变量 BQ_BASE 指定主目录。');
    process.exit(2);
  }

  const questlines = listQuestLines();

  if (queryArg === 'list' || queryArg === '--list' || queryArg === '-list') {
    printList(questlines);
    return;
  }

  let query = queryArg;
  if (query == null) {
    printList(questlines);
    console.log('');
    query = (await prompt('请输入章节名称、代码或序号：')).trim();
    if (!query) {
      console.error('[错误] 未输入任何内容');
      process.exit(1);
    }
  }

  let target = null;
  if (/^\d+$/.test(query)) {
    const idx = parseInt(query, 10) - 1;
    if (idx >= 0 && idx < questlines.length) target = questlines[idx];
  } else {
    const lower = query.toLowerCase();
    target = questlines.find(ql =>
      ql.name === query || ql.code === query || ql.dirName === query ||
      ql.name.toLowerCase() === lower || ql.dirName.toLowerCase() === lower
    ) || null;
  }

  if (!target) {
    console.error('[错误] 未找到匹配的任务章节：' + query);
    console.error('可用 `node gen_quests.js list` 查看全部章节。');
    process.exit(1);
  }

  // 找到对应的任务目录（Quests/<相同名称>-<相同代码>）
  let targetQDir = null;
  if (fs.existsSync(qDir)) {
    for (const d of fs.readdirSync(qDir)) {
      if (codeFromName(d) === target.code) {
        targetQDir = path.join(qDir, d);
        break;
      }
    }
  }
  if (!targetQDir || !fs.existsSync(targetQDir)) {
    console.error('[错误] 找不到任务目录：Quests/' + target.dirName);
    process.exit(1);
  }

  const quests = extractQuests(targetQDir);
  const content = buildOutput(quests);

  const safeName = stripFormat(target.name).replace(/[\\/:*?"<>|]/g, '_');
  const outFile = outOverride || path.join(base, safeName + '.txt');
  fs.writeFileSync(outFile, content, 'utf8');

  console.log('完成！');
  console.log('  章节：' + target.name + '  (' + target.code + ')');
  console.log('  任务数：' + quests.length);
  console.log('  输出文件：' + outFile);
}

main().catch(e => {
  console.error('[错误] ' + (e && e.message ? e.message : e));
  process.exit(1);
});
