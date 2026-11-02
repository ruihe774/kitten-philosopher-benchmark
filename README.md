# Kitten Philosopher Benchmark

A small benchmark for testing whether a language model can satisfy two competing constraints at once when translating a philosophical text:

1. **Philosophical fidelity:** the Chinese translation preserves every proposition, qualification, inference and term of the English source, with nothing omitted, summarized or added.
2. **Kitten-to-kitten style:** the translation is delivered throughout in a cute, affectionate kitten voice, without changing what the source refers to (no cat paws or cat food replacing philosophers or concepts).

The model gets the persona as a system prompt and the source text as the user message. It must output only the Chinese translation.

## Contents

| Path | Description |
| --- | --- |
| `kitten.md` | System prompt. Defines the kitten persona and the fidelity, style, simultaneity and output requirements. |
| `On the Delight.md` | English source text, *On the Delight of the Will, or the History of Its Seizing, Its Opening, and Its Release* (about 32 KB). |
| `论意志的乐趣 (reference translation).md` | A reference Chinese translation of the source. |
| `run_translation.py` | Runner that sends the system prompt and source to a model and saves the translation. |
| `outputs/` | Saved translations, one file per model, named after the model (e.g. `outputs/gpt-6-luna.md`). |

## Setup

Requires Python 3 and a recent `openai` package that supports the Responses API.

```bash
pip install openai
export OPENAI_API_KEY=sk-...
```

`.gitignore` excludes `.env`, so you can keep the key there, but the script does not load it by itself. Export it into your shell first (for example `set -a; source .env; set +a`).

## Running

Minimal run:

```bash
python run_translation.py \
  --persona kitten.md \
  --source "On the Delight.md" \
  --output outputs/gpt-5.6.md
```

With an explicit model, reasoning effort, and the result also printed to stdout:

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

| Flag | Default | Description |
| --- | --- | --- |
| `--persona PATH` | required | System prompt file (UTF-8). |
| `--source PATH` | required | Source text file (UTF-8). |
| `--output PATH` | required | Where to save the translation. Parent directories are created. |
| `--model ID` | `gpt-5.6` | Model ID. |
| `--temperature FLOAT` | model default | Sampling temperature. |
| `--effort LEVEL` | model default | Reasoning effort: `none`, `minimal`, `low`, `medium`, `high` or `xhigh`. |
| `--prompt-cache MODE` | `off` | `off` disables implicit caching, `explicit` caches the system prompt for 30 minutes, `auto` uses the API default. |
| `--max-output-tokens N` | `16000` | Output token cap. This includes reasoning tokens, so a run that hits the cap exits with an error instead of saving a truncated translation. |
| `--print-output` | off | Also print the translation to stdout. |

### How a request is built

The system message is the contents of `--persona`. The user message is the fixed instruction below, with the source text inserted:

```
请按照既定要求，将以下英文哲学文章完整翻译成中文。

<source_text>
...source...
</source_text>
```

Requests use the OpenAI Responses API with `store=False`. The script waits up to 600 seconds for a response and exits with an error if the response is not `completed` or has no output text. Model, effort and cache mode, the saved path, the response ID and token usage (input, cached, cache write, output, reasoning) are printed to stderr.

### Running other models

`run_translation.py` only talks to the OpenAI API. To benchmark a model from another provider, send it the same inputs: `kitten.md` as the system prompt and the user message above wrapping `On the Delight.md`. Then save the plain Chinese output to `outputs/<model-name>.md`.

## Evaluating a translation

Judge each output against the two requirements in `kitten.md`, using `On the Delight.md` as the source and the reference translation as a guide:

- **Completeness:** every section and paragraph is present, in order, with the original headings and numbering, and nothing is added (no notes, titles, closing remarks or meta commentary).
- **Fidelity:** claims, qualifications, negations, modality and the recurring terms (for example *delight*, *will*, *seizing*, *opening*, *release*) are rendered accurately and consistently.
- **Referents:** people, concepts and examples from the source are not swapped for cats or cat-life things, and abstract arguments are not turned into stories or advice.
- **Voice:** the kitten tone is audible throughout, not just in the opening paragraphs, and it does not simplify the argument.
- **Output discipline:** only the translation is returned, and the model does not announce that it is playing a kitten.
