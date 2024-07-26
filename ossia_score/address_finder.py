#!/usr/bin/env python3
import json
import re
import operator


with open("test.score", "r") as f:
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


def get_path_of_occurrences(data, key_to_find, path=""):
    """
    Recursively search for all occurrences of a specific key in dictionary.

    :param data: The data (can be a dictionary or list).
    :param key_to_find: The key to search for.
    :param path: The current path in the data structure.
    :return: A list of paths where the key is found.
    """
    occurrences = []

    if isinstance(data, dict):
        for k, v in data.items():
            new_path = f"{path}.{k}" if path else k
            if k == key_to_find:
                occurrences.append(new_path)
            occurrences.extend(get_path_of_occurrences(v, key_to_find, new_path))
    elif isinstance(data, list):
        for i, item in enumerate(data):
            new_path = f"{path}[{i}]"
            occurrences.extend(get_path_of_occurrences(item, key_to_find, new_path))

    return occurrences


# Returns NoneType object, when no paranthesis are found
def get_level_of_key(key: str):
    match = re.search(r'\[(\d+)\]', key)
    return match.group(1)
    #return re.search('[(.*)]', key)


def remove_paranthesis_from_string(element : str):
    return re.sub('\[|\]|0|1|2|3|4|5|6|7|8|9', '', element)


def cast_level_to_int(level):
    return int(level)


def delete_item_number_from_path(path: list, item_number):
    path.pop(item_number)
    return path


def concenate_list(path : list) -> str:
    new_string = ""
    for x in range(len(path)):
        if not x == len(path):
            new_string = new_string + path[x] + "."
    return new_string


def get_json_object_at_path(json_object, path):
    keys = path.split(".")
    current = json_object

    for key in keys:
        if contains_value_paranthesis(key):
            level = get_level_of_key(key)
            cleaned_key = remove_paranthesis_from_string(key)
            if cleaned_key in current and isinstance(current[cleaned_key], list) and int(level) < len(current[cleaned_key]):
                current = current[cleaned_key][int(level)]
            else:
                return None
        elif isinstance(current, dict) and key in current:
            current = current[key]
        else:
            return None

    return current


def contains_value_paranthesis(value):
    return "[" in value


# Key to search for
key_to_find = "ScriptingName"
searched_value = "Kaleidoscope"

# Find all occurrences of the key
# print(get_json_object_at_path(boli_score, occurrences[0]))

occurences = get_path_of_occurrences(boli_score, key_to_find, path="")

# print(get_json_object_at_path(boli_score, occurences[1]))
number = 3
print(occurences[number])

path = get_json_object_at_path(boli_score, occurences[number])
#Document.BaseScenario.Constraint.Processes[0].States[2].Metadata.ScriptingName
#print(boli_score["Document"]["BaseScenario"]["Constraint"]["Processes"][0]["States"][2])

#["States"][2]["Metadata"])
#print(boli_score["Document"]["BaseScenario"]["Constraint"]["Processes"][0]["TimeNodes"][2]["Metadata"])


# Print the JSON object
if path is not None:
    print(json.dumps(path, indent=4))
else:
    print(f"Path '{occurences[number]}' is invalid.")
