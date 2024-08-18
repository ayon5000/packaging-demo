from typing import Union, Any


def add_numbers(first_num: int, second_num: int) -> int:
    return first_num + second_num


def substract_numbers(first_num: int, second_num: int) -> int:
    return first_num - second_num


def multiply_numbers(first_num: int, second_num: int) -> int:
    return first_num * second_num


def divide_numbers(first_num: int, second_num: int) -> Union[int, Any]:
    if second_num != 0 and second_num is not None:
        return first_num / second_num
    else:
        raise ZeroDivisionError
