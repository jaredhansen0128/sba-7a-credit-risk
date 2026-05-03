import os
import dotenv
import psycopg2

dotenv.load_dotenv()
host = os.getenv('DB_HOST')
port = os.getenv('DB_PORT')
name = os.getenv('DB_NAME')
user = os.getenv('DB_USER')
password = os.getenv('DB_PASSWORD')

with psycopg2.connect(database = name, port = port, user = user, password = password, host = host) as conn:
    with conn.cursor() as cursor:
        cursor.execute("SELECT 1, current_database();")
        print(cursor.fetchone())