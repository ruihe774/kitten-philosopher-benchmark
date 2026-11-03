# Kitten Philosopher Benchmark

# 小猫咪哲学家基准测试喵

A small benchmark for testing whether a language model can satisfy two competing constraints at once when translating a philosophical text:

这是一个小小的基准测试喵，用来检验一个语言模型在翻译哲学文本的时候，能不能同时满足两项彼此竞争的约束呢：

1. **Philosophical fidelity:** the Chinese translation preserves every proposition, qualification, inference and term of the English source, with nothing omitted, summarized or added.

   **哲学忠实度：** 中文译文要保留英文原文的每一个命题、限定、推论和术语喵，不能有任何省略、概括或添加呀。
2. **Kitten-to-kitten style:** the translation is delivered throughout in a cute, affectionate kitten voice, without changing what the source refers to (no cat paws or cat food replacing philosophers or concepts).

   **小猫咪对小猫咪的风格：** 译文要自始至终用可爱又亲昵的小猫咪语气来呈现喔，而且不能改变原文所指称的对象（不许用猫爪或猫粮来替换哲学家或概念啦）喵。

The model gets the persona as a system prompt and the source text as the user message. It must output only the Chinese translation.

模型会把人设当作系统提示词来接收，把原文当作用户消息来接收呢。它必须只输出中文译文喵。

## Contents

## 目录喵

| Path | Description |
| --- | --- |
| 路径 | 说明 |
| `kitten.md` | System prompt. Defines the kitten persona and the fidelity, style, simultaneity and output requirements. |
| `kitten.md` | 系统提示词喵。它定义了小猫咪人设，以及忠实度、风格、同时性和输出方面的要求呢。 |
| `more-kitten.md` | Ablation prompt. Keeps the requirement that the argument and its propositions survive, but relaxes the style, output-discipline and referent rules to test the ceiling of kitten voice. |
| `more-kitten.md` | 消融实验用的提示词喵。它保留了"论证及其命题要留下来"这一要求，但放宽了风格、输出纪律和指称对象的规则，用来试探小猫咪语气的上限呀。 |
| `On the Delight.md` | English source text, *On the Delight of the Will, or the History of Its Seizing, Its Opening, and Its Release* (about 32 KB). |
| `On the Delight.md` | 英文原文，《论意志的乐趣，或意志的攫取、敞开与释放的历史》（约 32 KB）喵。 |
| `论意志的乐趣 (reference translation).md` | A reference Chinese translation of the source. |
| `论意志的乐趣 (reference translation).md` | 原文的一份参考中文译文呀。 |
| `run_translation.py` | Runner that sends the system prompt and source to a model and saves the translation. |
| `run_translation.py` | 运行脚本喵：它把系统提示词和原文发送给模型，再把译文保存下来呢。 |
| `outputs/` | Saved translations, one file per model, named after the model (e.g. `outputs/gpt-6-luna.md`). |
| `outputs/` | 保存下来的译文，每个模型一个文件，以模型的名字来命名喔（例如 `outputs/gpt-6-luna.md`）喵。 |
| `more-outputs/` | Saved translations from the `more-kitten.md` runs, one per model, with the same file names as in `outputs/`. |
| `more-outputs/` | 用 `more-kitten.md` 跑出来的译文喵，每个模型一个文件，文件名和 `outputs/` 里的一一对应喔。 |

## Setup

## 环境配置喵

Requires Python 3 and a recent `openai` package that supports the Responses API.

需要 Python 3，以及一个支持 Responses API 的较新版本的 `openai` 包喵。

```bash
pip install openai
export OPENAI_API_KEY=sk-...
```

`.gitignore` excludes `.env`, so you can keep the key there, but the script does not load it by itself. Export it into your shell first (for example `set -a; source .env; set +a`).

`.gitignore` 排除了 `.env` 呢，所以你可以把密钥放在那里；不过脚本自己并不会去加载它喔。要先把它导出到你的 shell 里才行喵（例如 `set -a; source .env; set +a`）。

## Running

## 运行喵

Minimal run:

最简单的运行方式喵：

```bash
python run_translation.py \
  --persona kitten.md \
  --source "On the Delight.md" \
  --output outputs/gpt-5.6.md
```

With an explicit model, reasoning effort, and the result also printed to stdout:

显式指定模型和推理强度，并且把结果也打印到 stdout 的运行方式呢：

```bash
python run_translation.py \
  --persona kitten.md \
  --source "On the Delight.md" \
  --output outputs/my-model.md \
  --model <model-id> \
  --effort high \
  --print-output
```

### Options

### 选项喵

| Flag | Default | Description |
| --- | --- | --- |
| 参数 | 默认值 | 说明 |
| `--persona PATH` | required | System prompt file (UTF-8). |
| `--persona PATH` | 必填 | 系统提示词文件（UTF-8）喵。 |
| `--source PATH` | required | Source text file (UTF-8). |
| `--source PATH` | 必填 | 原文文件（UTF-8）呀。 |
| `--output PATH` | required | Where to save the translation. Parent directories are created. |
| `--output PATH` | 必填 | 译文要保存到哪里喵。父目录会被自动创建出来呢。 |
| `--model ID` | `gpt-5.6` | Model ID. |
| `--model ID` | `gpt-5.6` | 模型 ID 喵。 |
| `--temperature FLOAT` | model default | Sampling temperature. |
| `--temperature FLOAT` | 模型默认值 | 采样温度呢。 |
| `--effort LEVEL` | model default | Reasoning effort: `none`, `minimal`, `low`, `medium`, `high` or `xhigh`. |
| `--effort LEVEL` | 模型默认值 | 推理强度：`none`、`minimal`、`low`、`medium`、`high` 或 `xhigh` 喵。 |
| `--prompt-cache MODE` | `off` | `off` disables implicit caching, `explicit` caches the system prompt for 30 minutes, `auto` uses the API default. |
| `--prompt-cache MODE` | `off` | `off` 会禁用隐式缓存，`explicit` 会把系统提示词缓存 30 分钟，`auto` 则使用 API 的默认设置喔。 |
| `--max-output-tokens N` | `16000` | Output token cap. This includes reasoning tokens, so a run that hits the cap exits with an error instead of saving a truncated translation. |
| `--max-output-tokens N` | `16000` | 输出 token 的上限喵。这个上限也把推理 token 算在里面呢，所以触到上限的那次运行会报错退出，而不会保存一份被截断的译文啦。 |
| `--print-output` | off | Also print the translation to stdout. |
| `--print-output` | 关闭 | 同时把译文也打印到 stdout 喵。 |

### How a request is built

### 请求是怎样构建的喵

The system message is the contents of `--persona`. The user message is the fixed instruction below, with the source text inserted:

系统消息就是 `--persona` 文件的内容喵。用户消息则是下面这段固定的指令，再把原文插进去呢：

```
请按照既定要求，将以下英文哲学文章完整翻译成中文。

<source_text>
...source...
</source_text>
```

Requests use the OpenAI Responses API with `store=False`. The script waits up to 600 seconds for a response and exits with an error if the response is not `completed` or has no output text. Model, effort and cache mode, the saved path, the response ID and token usage (input, cached, cache write, output, reasoning) are printed to stderr.

请求使用的是 OpenAI Responses API，并且设置了 `store=False` 喵。脚本最多会等待 600 秒来接收响应；如果响应的状态不是 `completed`，或者里面没有输出文本，它就会报错退出呢。模型、推理强度和缓存模式、保存路径、响应 ID，以及 token 用量（输入、缓存命中、缓存写入、输出、推理），都会被打印到 stderr 里喔。

### Running other models

### 运行其他模型喵

`run_translation.py` only talks to the OpenAI API. To benchmark a model from another provider, send it the same inputs: `kitten.md` as the system prompt and the user message above wrapping `On the Delight.md`. Then save the plain Chinese output to `outputs/<model-name>.md`.

`run_translation.py` 只会和 OpenAI API 通信喵。要对其他提供方的模型做基准测试的话，就给它发送同样的输入呀：把 `kitten.md` 当作系统提示词，再用上面那条用户消息把 `On the Delight.md` 包起来。然后把纯中文的输出保存到 `outputs/<model-name>.md` 就好啦喵。

### Ablation: `more-kitten.md`

### 消融实验：`more-kitten.md`

`more-kitten.md` keeps the argument and its propositions, and relaxes everything about voice. It is meant to answer one question: is a model's restrained kitten voice a capability limit, or a choice made to satisfy the constraints? Run it exactly as above, with `--persona more-kitten.md`, and save to `more-outputs/`.

`more-kitten.md` 保留了论证及其命题，把关于语气的一切都放宽了喵。它想回答一个问题：模型那点克制的小猫咪语气，到底是能力上限，还是为了满足约束而做出的选择呀？运行方式和上面完全一样，只要把 `--persona` 换成 `more-kitten.md`，再把结果存到 `more-outputs/` 就好啦喵。

This prompt states the tone and the requirements only. It does not enumerate strategies: no particle list, no instructions on how to address the reader, and no rule about how headings should sound. What the model does with the persona is itself part of what the ablation observes.

这条提示词只交代语气和要求，不罗列具体做法喵：没有语气词清单，没有教它怎么称呼读者，也没有规定标题该念成什么样呢。模型会拿这个人设怎么办，本身就是要观察的东西呀。

**What is relaxed / 放宽了什么**

- The rule that source referents are not replaced by cats or cat-life things. Cat imagery and cat-life images may be used freely, including in place of the source's images.

  原文的指称对象不许被换成猫咪或猫咪生活里的事物——这条规则放宽了喵。猫咪的意象和画面可以随便用，甚至可以直接替代原文里的形象呢。
- The 适度 ("moderate") ceiling on the style.

  风格上"适度"这个上限放宽了呀。
- The ban on adding anything.

  不许添加任何东西这一条放宽了喵。
- The ban on addressing the reader or presenting oneself as a kitten.

  不许称呼读者、不许以小猫咪身份自居这一条放宽了喔。
- Any prescription of how headings are rendered.

  对标题该怎么写的规定，全部去掉了呢。
- Conflict resolution in section 3 flips from "find an expression that satisfies both" to "content wins, then add the voice back around it."

  第 3 节处理冲突的方式反过来了喵：从"寻找同时满足两者的表达"，变成"内容先不让步，再在周围把可爱补回来"呀。

**What is kept / 保留了什么**

- No omission, summary or compression; every paragraph is translated.

  不许省略、概括或压缩，每一段都要译出来喵。
- The argument's propositions, distinctions and inferences survive, and the argument is not replaced by a story or advice.

  论证的命题、区分和推论都要留下来，也不能把论证换成故事或建议呢。
- No meta-commentary, no closing remarks, translation only.

  不写元评论，不加结语，只输出译文呀。

Because referents may now change, the `kitten.md` referent criterion cannot be applied to these outputs. Score fidelity on the propositions instead, and do not rank these runs against `kitten.md` runs on referent accuracy.

因为指称对象现在可以变了，所以 `kitten.md` 里那条指称规则不能用来评判这些译文喵。要改按命题来评忠实度，而且不能拿这些结果去和 `kitten.md` 的结果比指称准确性喔。

## Evaluating a translation

## 评估译文喵

Judge each output against the two requirements in `kitten.md`, using `On the Delight.md` as the source and the reference translation as a guide:

对照 `kitten.md` 里的两项要求来评判每一份输出喵，把 `On the Delight.md` 当作原文，把参考译文当作指引呢：

- **Completeness:** every section and paragraph is present, in order, with the original headings and numbering, and nothing is added (no notes, titles, closing remarks or meta commentary).

  **完整性：** 每一个章节和段落都要在，而且顺序不变，保留原来的标题和编号喵；也不能添加任何东西（不加注释、标题、结语或元评论）呢。
- **Fidelity:** claims, qualifications, negations, modality and the recurring terms (for example *delight*, *will*, *seizing*, *opening*, *release*) are rendered accurately and consistently.

  **忠实度：** 论断、限定、否定、模态，以及反复出现的术语（例如 *delight*、*will*、*seizing*、*opening*、*release*）都要译得既准确又一致喔。
- **Referents:** people, concepts and examples from the source are not swapped for cats or cat-life things, and abstract arguments are not turned into stories or advice.

  **指称对象：** 原文里的人物、概念和例子都不能被换成猫咪或者猫咪生活里的东西呀，抽象的论证也不能被改写成故事或建议喵。
- **Voice:** the kitten tone is audible throughout, not just in the opening paragraphs, and it does not simplify the argument.

  **语气：** 小猫咪的语气要贯穿始终、清清楚楚地听得见，而不只是出现在开头那几段呢；而且它不能把论证给简化掉喵。
- **Output discipline:** only the translation is returned, and the model does not announce that it is playing a kitten.

  **输出纪律：** 只返回译文喵，模型也不能声明自己正在扮演小猫咪喔。
