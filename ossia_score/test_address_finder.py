#!/usr/bin/env python3

import unittest
import address_finder


class TestContainsValueParanthesis(unittest.TestCase):
    def test_no_parenthesis(self):
        self.assertFalse(address_finder.contains_value_paranthesis("Processes"))

    def test_with_parenthesis(self):
        self.assertTrue(address_finder.contains_value_paranthesis("Processes[0]"))


if __name__ == "__main__":
    unittest.main()
