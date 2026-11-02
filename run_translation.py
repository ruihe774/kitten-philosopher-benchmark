#!/usr/bin/env python3
"""Run a translation task using the OpenAI Responses API."""

import argparse
import sys
from pathlib import Path

from openai import OpenAI


USER_INSTRUCTION = (
    "请按照既定要求，将以下英文哲学文章完整翻译成中文。\n\n"
    "<source_text>\n{source}\n</source_text>"
)


def parse_args():
    parser = argparse.ArgumentParser(
        description="Run a translation task with the Responses API."
    )

    parser.add_argument(
        "--persona",
        type=Path,
        required=True,
        help="Path to the system prompt (UTF-8).",
    )
    parser.add_argument(
        "--source",
        type=Path,
        required=True,
        help="Path to the source text (UTF-8).",
    )
    parser.add_argument(
        "--output",
        type=Path,
        required=True,
        help="Path to save the translation.",
    )
    parser.add_argument(
        "--model",
        default="gpt-5.6",
        help="OpenAI model ID (default: gpt-5.6).",
    )
    parser.add_argument(
        "--temperature",
        type=float,
        default=None,
        help="Sampling temperature; omit for model default.",
    )
    parser.add_argument(
        "--effort",
        choices=[
            "none",
            "minimal",
            "low",
            "medium",
            "high",
            "xhigh",
        ],
        default=None,
        help="Reasoning effort; omit for model default.",
    )
    parser.add_argument(
        "--prompt-cache",
        choices=["auto", "off", "explicit"],
        default="off",
        help="Prompt caching mode (default: off).",
    )
    parser.add_argument(
        "--max-output-tokens",
        type=int,
        default=16000,
        help="Maximum output tokens (default: 16000).",
    )
    parser.add_argument(
        "--print-output",
        action="store_true",
        help="Also print the translation to stdout.",
    )

    return parser.parse_args()


def build_request(args, persona, source):
    user_prompt = USER_INSTRUCTION.format(source=source)

    system_message = {
        "role": "system",
        "content": persona,
    }

    user_message = {
        "role": "user",
        "content": user_prompt,
    }

    request = {
        "model": args.model,
        "input": [system_message, user_message],
        "max_output_tokens": args.max_output_tokens,
        "store": False,
    }

    if args.temperature is not None:
        request["temperature"] = args.temperature

    if args.effort is not None:
        request["reasoning"] = {
            "effort": args.effort,
        }

    if args.prompt_cache == "off":
        # Explicit mode with no breakpoints:
        # disables implicit prompt caching.
        request["prompt_cache_options"] = {
            "mode": "explicit",
        }

    elif args.prompt_cache == "explicit":
        # Cache the stable system prompt.
        request["prompt_cache_options"] = {
            "mode": "explicit",
            "ttl": "30m",
        }
        system_message["prompt_cache_breakpoint"] = {
            "type": "default",
        }

    # auto: use API default implicit caching.

    return request


def print_usage(response):
    usage = response.usage
    if usage is None:
        return

    input_details = getattr(
        usage, "input_tokens_details", None
    )
    output_details = getattr(
        usage, "output_tokens_details", None
    )

    cached_tokens = (
        getattr(input_details, "cached_tokens", 0)
        if input_details else 0
    )
    cache_write_tokens = (
        getattr(input_details, "cache_write_tokens", 0)
        if input_details else 0
    )
    reasoning_tokens = (
        getattr(output_details, "reasoning_tokens", 0)
        if output_details else 0
    )

    print(
        f"Input tokens: {usage.input_tokens}",
        file=sys.stderr,
    )
    print(
        f"Cached tokens: {cached_tokens}",
        file=sys.stderr,
    )
    print(
        f"Cache write tokens: {cache_write_tokens}",
        file=sys.stderr,
    )
    print(
        f"Output tokens: {usage.output_tokens}",
        file=sys.stderr,
    )
    print(
        f"Reasoning tokens: {reasoning_tokens}",
        file=sys.stderr,
    )


def main():
    args = parse_args()

    persona = args.persona.read_text(
        encoding="utf-8"
    ).strip()

    source = args.source.read_text(
        encoding="utf-8"
    ).strip()

    if not persona:
        raise ValueError("Persona file is empty.")

    if not source:
        raise ValueError("Source file is empty.")

    request = build_request(args, persona, source)

    client = OpenAI(timeout=600.0)

    print(f"Model: {args.model}", file=sys.stderr)
    print(
        f"Reasoning effort: {args.effort or 'default'}",
        file=sys.stderr,
    )
    print(
        f"Prompt cache: {args.prompt_cache}",
        file=sys.stderr,
    )
    print(
        "Sending translation request...",
        file=sys.stderr,
    )

    response = client.responses.create(**request)

    if response.status != "completed":
        raise RuntimeError(
            f"Response did not complete: {response.status}; "
            f"details: {response.incomplete_details}"
        )

    translation = response.output_text

    if not translation or not translation.strip():
        raise RuntimeError(
            "Response contains no output text."
        )

    args.output.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    args.output.write_text(
        translation,
        encoding="utf-8",
    )

    print(
        f"Saved: {args.output}",
        file=sys.stderr,
    )
    print(
        f"Response ID: {response.id}",
        file=sys.stderr,
    )

    print_usage(response)

    if args.print_output:
        print(translation)


if __name__ == "__main__":
    main()
