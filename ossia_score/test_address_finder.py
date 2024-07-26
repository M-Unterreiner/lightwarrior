#!/usr/bin/env python3

import unittest
import address_finder
import json


class TestCastLevelToInt(unittest.TestCase):
    def test_cast_level_to_int(self):
        self.assertEqual(address_finder.cast_level_to_int("0"), 0)


class TestGetLevelOfKey(unittest.TestCase):
    def test_get_level(self):
        key = "Processes[0]"
        level = address_finder.get_level_of_key(key)

        self.assertEqual(level, "0")

class TestKeyOccurrences(unittest.TestCase):
    def test_test_score(self):

        with open("test.score", "r") as f:
            test_score = json.load(f)

        reference_occurrences = ['Document.BaseScenario.Constraint.Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].TimeNodes[0].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].TimeNodes[1].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].TimeNodes[2].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].Events[0].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].Events[1].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].Events[2].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].States[0].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].States[1].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].States[2].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].States[3].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].States[4].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].States[5].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].Constraints[0].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].Constraints[1].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].Constraints[1].Processes[0].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].Constraints[1].Processes[1].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].Constraints[1].Processes[2].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].Constraints[1].Processes[3].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].Constraints[1].Processes[4].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[0].Constraints[2].Metadata.ScriptingName', 'Document.BaseScenario.Constraint.Processes[1].Metadata.ScriptingName', 'Document.BaseScenario.StartTimeNode.Metadata.ScriptingName', 'Document.BaseScenario.EndTimeNode.Metadata.ScriptingName', 'Document.BaseScenario.StartEvent.Metadata.ScriptingName', 'Document.BaseScenario.EndEvent.Metadata.ScriptingName', 'Document.BaseScenario.StartState.Metadata.ScriptingName', 'Document.BaseScenario.EndState.Metadata.ScriptingName']
        occurrences = address_finder.get_path_of_occurrences(test_score, "ScriptingName", "")
        self.assertListEqual(occurrences, reference_occurrences)

class TestGetJsonObjectAtPath(unittest.TestCase):
    def test_json_object_at_path(self):
        with open("test.score", "r") as f:
            test_score = json.load(f)



class TestGetJsonObjectAtPath(unittest.TestCase):
    def test_reduce_path(self):
        path = "Document.BaseScenario.Constraint.Metadata.ScriptingName"
        path_dict = path.split(".")
        length_of_dict = len(path_dict)
        new_length_of_dict = len(address_finder.delete_item_number_from_path(path_dict, 0))
        self.assertEqual(new_length_of_dict, length_of_dict - 1)

class TestContainsValueParanthesis(unittest.TestCase):
    def test_no_parenthesis(self):
        self.assertFalse(address_finder.contains_value_paranthesis("Processes"))

    def test_with_parenthesis(self):
        self.assertTrue(address_finder.contains_value_paranthesis("Processes[0]"))


if __name__ == "__main__":
    unittest.main()
