import csv
import json
import sys
import re

def transform_csv_to_json(csv_file):
    json_data = {}
    with open(csv_file, 'r', newline='', encoding='utf-8-sig') as file:
        csv_reader = csv.DictReader(file)
        for row in csv_reader:
            row_id = row.pop('id')  # Remove and get the 'id' field as the key
            # Process description: drop non-English basic characters and crop to 50 characters max
            description = re.sub(r'[^\x00-\x7F]', '', row['description'])[:50]
            json_data[row_id] = {
                k.strip(): v.strip().replace('\ufeff', '') if k != 'description' else description
                for k, v in row.items()
            }
            try:
                # Convert 'amount' and 'timestamp' to appropriate types
                json_data[row_id]['amount'] = float(json_data[row_id]['amount'])
                json_data[row_id]['timestamp'] = int(json_data[row_id]['timestamp'])
            except ValueError:
                print(f"Error processing row: {json.dumps(row)}")
                raise
    return json_data

def save_json(json_data, output_file):
    with open(output_file, 'w') as file:
        json.dump(json_data, file, indent=2)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <input_csv_file>")
        sys.exit(1)

    input_csv = sys.argv[1]
    output_json = input_csv[:-4] + "-transformed.json"

    transformed_data = transform_csv_to_json(input_csv)
    save_json(transformed_data, output_json)
    print(f"Transformation complete. JSON data saved to {output_json}")
