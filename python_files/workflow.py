import json

def parse_json_structure(json_data, field):
    """Function to parse JSON structure and check if the given field is an array or object."""
    keys = field.split(".")
    current = json_data
    for key in keys:
        if isinstance(current, list):
            current = current[0]  # Assuming all elements in the array have the same structure
        if key in current:
            current = current[key]
        else:
            raise ValueError(f"Field {key} not found in JSON.")
    return current

def build_workflow(fields, json_file_path, source_table="source_table", workflow_name="dynamic_workflow"):
    # Load the JSON file to check the structure
    with open(json_file_path, 'r') as json_file:
        json_data = json.load(json_file)

    # Initialize the base workflow structure
    workflow = {
        "workflow_name": workflow_name,
        "steps": []
    }

    # Workflow Position 1: Select columns
    step_1 = {
        "workflow_position": 1,
        "operation_type": "select_columns",
        "operation": {
            "source_entity_name": source_table,
            "target_config": {
                "target_entity_name": f"{workflow_name}_01"
            },
            "config": {
                "column_names": [
                    "readoutid", "contexts", "dealer", "sessionstarttime"
                ]
            }
        }
    }
    workflow["steps"].append(step_1)

    # Workflow Position 2: From JSON to handle "contexts"
    step_2 = {
        "workflow_position": 2,
        "operation_type": "from_json",
        "operation": {
            "source_entity_name": f"{workflow_name}_01",
            "target_config": {
                "target_entity_name": f"{workflow_name}_02"
            },
            "config": {
                "column_name": "contexts",
                "new_column_name": "contexts_array",
                "column_schema": "ArrayType(StringType())"
            }
        }
    }
    workflow["steps"].append(step_2)

    # Workflow Position 3: Explode contexts array
    step_3 = {
        "workflow_position": 3,
        "operation_type": "curation",
        "operation": {
            "source_entity_name": f"{workflow_name}_02",
            "target_config": {
                "target_entity_name": f"{workflow_name}_03"
            },
            "config": {
                "custom_columns": [
                    {
                        "sql_expression": "explode_outer(contexts_array)",
                        "new_column_name": "context_exploded"
                    }
                ]
            }
        }
    }
    workflow["steps"].append(step_3)

    # Workflow Position 4: Extract vehicleData and contextId
    step_4 = {
        "workflow_position": 4,
        "operation_type": "curation",
        "operation": {
            "source_entity_name": f"{workflow_name}_03",
            "target_config": {
                "target_entity_name": f"{workflow_name}_04"
            },
            "config": {
                "custom_columns": [
                    {
                        "sql_expression": "json_tuple(context_exploded,'vehicleData')",
                        "new_column_name": "vehicle_data"
                    },
                    {
                        "sql_expression": "json_tuple(context_exploded,'contextId')",
                        "new_column_name": "context_id"
                    }
                ]
            }
        }
    }
    workflow["steps"].append(step_4)

    # Workflow Position 5: Handle vehicle_data as JSON array
    step_5 = {
        "workflow_position": 5,
        "operation_type": "from_json",
        "operation": {
            "source_entity_name": f"{workflow_name}_04",
            "target_config": {
                "target_entity_name": f"{workflow_name}_05"
            },
            "config": {
                "column_name": "vehicle_data",
                "new_column_name": "vehicle_data_array",
                "column_schema": "ArrayType(StringType())"
            }
        }
    }
    workflow["steps"].append(step_5)

    # Workflow Position 6: Explode vehicle_data array
    step_6 = {
        "workflow_position": 6,
        "operation_type": "curation",
        "operation": {
            "source_entity_name": f"{workflow_name}_05",
            "target_config": {
                "target_entity_name": f"{workflow_name}_06"
            },
            "config": {
                "custom_columns": [
                    {
                        "sql_expression": "explode_outer(vehicle_data_array)",
                        "new_column_name": "vehicle_data_exploded"
                    }
                ]
            }
        }
    }
    workflow["steps"].append(step_6)

    # Workflow Position 7: Extract vehicleOrderData
    step_7 = {
        "workflow_position": 7,
        "operation_type": "curation",
        "operation": {
            "source_entity_name": f"{workflow_name}_06",
            "target_config": {
                "target_entity_name": f"{workflow_name}_07"
            },
            "config": {
                "custom_columns": [
                    {
                        "sql_expression": "json_tuple(vehicle_data_exploded,'vehicleOrderData')",
                        "new_column_name": "vehicle_order_data"
                    }
                ]
            }
        }
    }
    workflow["steps"].append(step_7)

    # Workflow Position 8: Handle vehicle_order_data as JSON array
    step_8 = {
        "workflow_position": 8,
        "operation_type": "from_json",
        "operation": {
            "source_entity_name": f"{workflow_name}_07",
            "target_config": {
                "target_entity_name": f"{workflow_name}_08"
            },
            "config": {
                "column_name": "vehicle_order_data",
                "new_column_name": "vehicle_order_data_array",
                "column_schema": "ArrayType(StringType())"
            }
        }
    }
    workflow["steps"].append(step_8)

    # Workflow Position 9: Explode vehicle_order_data array
    step_9 = {
        "workflow_position": 9,
        "operation_type": "curation",
        "operation": {
            "source_entity_name": f"{workflow_name}_08",
            "target_config": {
                "target_entity_name": f"{workflow_name}_09"
            },
            "config": {
                "custom_columns": [
                    {
                        "sql_expression": "explode_outer(vehicle_order_data_array)",
                        "new_column_name": "vehicle_order_data_exploded"
                    }
                ]
            }
        }
    }
    workflow["steps"].append(step_9)

    # Workflow Position 10: Dynamically extract fields provided by the user
    custom_columns = []
    for field in fields:
        # Parse the JSON to check the structure and determine if it's an array or object
        structure = parse_json_structure(json_data, field)
        parts = field.split(".")
        last_part = parts[-1]

        # Depending on whether it's a scalar or complex type, we can adjust how we extract it
        custom_columns.append({
            "sql_expression": f"json_tuple(vehicle_order_data_exploded,'{last_part}')",
            "new_column_name": f"{last_part}"
        })

    step_10 = {
        "workflow_position": 10,
        "operation_type": "curation",
        "operation": {
            "source_entity_name": f"{workflow_name}_09",
            "target_config": {
                "target_entity_name": f"{workflow_name}_10"
            },
            "config": {
                "custom_columns": custom_columns
            }
        }
    }
    workflow["steps"].append(step_10)

    # Workflow Position 11: Select final columns
    step_11 = {
        "workflow_position": 11,
        "operation_type": "select_columns",
        "operation": {
            "source_entity_name": f"{workflow_name}_10",
            "target_config": {
                "target_entity_name": f"{workflow_name}_final"
            },
            "config": {
                "column_names": [
                    "readoutid", "context_id", *[field.split(".")[-1] for field in fields], "sessionstarttime"
                ]
            }
        }
    }
    workflow["steps"].append(step_11)

    return workflow

# Example usage
fields_to_extract = [
    "vehicleData.vehicleOrderData.equipments",
    "vehicleData.vehicleOrderData.eWords",
    "vehicleData.vehicleOrderData.hoWords"
]

json_file_path = r"C:\Users\ahmet.bolat\Desktop\notepad++\test.json" # Path to the JSON file

workflow = build_workflow(fields_to_extract, json_file_path=json_file_path, source_table="vehicle_fasta_source", workflow_name="te_vehicle_order")
print(json.dumps(workflow, indent=4))
