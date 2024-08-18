from typing import Any

try:
    from rich import print
except ImportError:
    ...


def print_me(text: Any) -> None:
    print(text)
