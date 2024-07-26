#!/usr/bin/env python3
import json


with open("boli.score", "r") as f:
    # Load the JSON json_object
    boli_score = json.load(f)


def search_in_json_for_key(json_obj, key):
    """
    Recursively search for a key in a JSON object and return its value.
    """
    if isinstance(json_obj, dict):
        for k, v in json_obj.items():
            if k == key:
                return v
            elif isinstance(v, (dict, list)):
                result = search_in_json_for_key(v, key)
                if result is not None:
                    return result
    elif isinstance(json_obj, list):
        for item in json_obj:
            result = search_in_json_for_key(item, key)
            if result is not None:
                return result
    return None


def find_key_occurrences(json_object, key_to_find, path=""):
    """
    Recursively search for all occurrences of a specific key in a JSON object.

    :param json_object: The JSON data (can be a dictionary or list).
    :param key_to_find: The key to search for.
    :param path: The current path in the JSON structure.
    :return: A list of paths where the key is found.
    """
    occurrences = []

    if isinstance(json_object, dict):
        for k, v in json_object.items():
            new_path = f"{path}.{k}" if path else k
            if k == key_to_find:
                occurrences.append(new_path)
            occurrences.extend(find_key_occurrences(v, key_to_find, new_path))
    elif isinstance(json_object, list):
        for i, item in enumerate(json_object):
            new_path = f"{path}[{i}]"
            occurrences.extend(find_key_occurrences(item, key_to_find, new_path))

    return occurrences


def concenate_path(path, last_item_number):
    new_string = ""
    for x in range(len(path)):
        new_string = new_string + path[x]


def find_last_path(path, current):
    print("find_last_path:", path)
    for x in range(len(path)):
        if path[x] == current:
            return concenate_path(path, x)
    return "Path not found"


def get_json_object_at_path(json_object, path):
    """
    Retrieve the JSON object at the given path.

    :param json_object: The JSON data (can be a dictionary or list).
    :param path: The path to the desired JSON object (e.g., "address.city" or "courses[0].name").
    :return: The JSON object at the given path, or None if the path is invalid.
    """
    keys = path.split(".")
    current = json_object

    for key in keys:
        if isinstance(current, dict) and key in current:
            print(key, " was found")
            current = current[key]
        elif isinstance(current, list) and key.isdigit() and int(key) < len(current):
            current = current[int(key)]
        else:
            print(find_last_path(keys, current))
            return None

    return current


def contains_value_paranthesis(value):
    return "[" in value


# Key to search for
key_to_find = "ScriptingName"
searched_value = "Kaleidoscope"

# Find all occurrences of the key

# print(get_json_object_at_path(boli_score, occurrences[0]))


print(find_key_occurrences(boli_score, key_to_find, path=""))
#print(contains_value_paranthesis("Processes[0]"))
#print(contains_value_paranthesis("Processes"))
