from mypackage.math.binary_operations import add_numbers
import pytest

@pytest.mark.parametrize(
        argnames = "first_num, second_num, result, is_passed",
        argvalues =[
            (1,2,3, True),
            (4,6,10, True),
            (21,20,41, True),
            (50,50,100, True),
            (50,50,101, False),
        ]
)
def test__binary_operations(first_num: int, second_num: int, result: int, is_passed: bool):
    test_result = add_numbers(first_num,second_num) == result
    assert test_result == is_passed