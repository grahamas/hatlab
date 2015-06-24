"""
	Validate existing records. Ignoring past logs b/c
	they are malformatted (i.e. results.txt)
"""

import os
import json
import argparse
import safe_file_ops as sop


### Constants ###

RECORD_NAME = 'record.json'

#################

### Functions ###

def combine_records(old_record, new_record):
	pass

def parse_log(record_path):
	all_records = sop.get_all_versions(record_path)
	record_dict = {}
	for record_name in all_records:
		with open(record_path, 'r') as record_file:
			new_record_dict = json.load(record_file)




def validate_records(root_path, monkey_name):
	if not os.path.isdir(root_path):
		raise ValueError("Invalid root_path.")

	monkey_dir = os.path.join(root_path, monkey_name)

	if not os.path.isdir(monkey_dir):
		raise ValueError("No such monkey directory.")

	record_path = os.path.join(monkey_dir, RECORD_NAME)




#################

### Main ###

def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("--root_path", action="store",
		description="""The path of the root directory where the log\
		files are stored, and where the monkey directory is.""")
	parser.add_argument("--monkey_name", action="store",
		description="""The monkey's name.
		Must correspond to subdirectory of root.""")
	args = parser.parse_args()

	root_path = args.root_path
	monkey_name = args.monkey_name

	validate_records(root_path, monkey_name)

if __name__ == "__main__":
	main()

#############