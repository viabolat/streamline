# ===get sql tables and columns===

import sqlparse
import re

def extract_tables_and_columns(sql_query):
    tables = set()
    columns = set()
    
    # Regular expression to match table names in FROM and JOIN clauses
    table_pattern = re.compile(r'\b(?:FROM|JOIN)\s+([^\s\(\)]+)')
    matches = table_pattern.findall(sql_query)
    
    # Normalize table names (remove potential schema prefixes)
    for match in matches:
        table_name = match.split('.')[-1]  # Get the table name without schema prefix
        tables.add(table_name)
    
    # Parse SQL query for column extraction
    parsed = sqlparse.parse(sql_query)
    
    for statement in parsed:
        # Extract columns from SELECT clause
        if statement.get_type() == 'SELECT':
            formatted_query = sqlparse.format(str(statement), strip_comments=True)
            column_pattern = re.compile(r'SELECT\s+(.*?)\s+(FROM|WHERE|GROUP BY|ORDER BY|LIMIT)', re.IGNORECASE | re.DOTALL)
            match = column_pattern.search(formatted_query)
            if match:
                columns_str = match.group(1)
                columns.update(col.strip() for col in columns_str.split(','))
    
    return tables, columns

# SQL query
sql_query = """


"""

# Extract tables and columns
tables, columns = extract_tables_and_columns(sql_query)

print("Tables used in the query:", tables)
print("Columns used in the query:", columns)
