from time import sleep


def slow_add(first_num: int, second_num: int) -> int:
    sleep(10)
    return first_num + second_num
