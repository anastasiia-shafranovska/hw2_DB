import uuid
import random
from datetime import datetime, timedelta

import psycopg2
from psycopg2.extras import execute_values
from faker import Faker


# Connection settings
HOST = 'localhost' # put your credentials here
USER = 'postgres' # put your credentials here
PASSWORD = '123456' # put your credentials here
DATABASE = 'opt_db' # put your credentials here
PORT = '5432' # put your credentials here

# Data volume settings
CLIENTS_COUNT = 100_000
PRODUCTS_COUNT = 10_000
ORDERS_COUNT = 1_000_000
CHUNK_SIZE = 10_000

fake = Faker()


def insert_clients(cursor):
    print("Inserting into opt_clients...")

    client_insert_query = """
        INSERT INTO opt_clients
            (id, name, surname, email, phone, address, status)
        VALUES %s
    """

    client_ids = []

    for start in range(0, CLIENTS_COUNT, CHUNK_SIZE):
        current_chunk_size = min(CHUNK_SIZE, CLIENTS_COUNT - start)

        clients_data = []
        for _ in range(current_chunk_size):
            client_id = str(uuid.uuid4())
            client_ids.append(client_id)

            clients_data.append(
                (
                    client_id,
                    fake.first_name(),
                    fake.last_name(),
                    fake.email(),
                    fake.phone_number(),
                    fake.address(),
                    random.choice(["active", "inactive"]),
                )
            )

        execute_values(cursor, client_insert_query, clients_data)
        print(f"Inserted {start + current_chunk_size} rows into opt_clients...")

    print("Inserted into opt_clients.")
    return client_ids


def insert_products(cursor):
    print("Inserting into opt_products...")

    product_insert_query = """
        INSERT INTO opt_products
            (product_name, product_category, description)
        VALUES %s
        RETURNING product_id
    """

    categories = ["Category1", "Category2", "Category3", "Category4", "Category5"]

    products_data = [
        (
            fake.word(),
            random.choice(categories),
            fake.text(),
        )
        for _ in range(PRODUCTS_COUNT)
    ]

    execute_values(cursor, product_insert_query, products_data)

    product_ids = [row[0] for row in cursor.fetchall()]

    print("Inserted into opt_products.")
    return product_ids


def insert_orders(cursor, client_ids, product_ids):
    print("Inserting into opt_orders...")

    order_insert_query = """
        INSERT INTO opt_orders
            (order_date, client_id, product_id)
        VALUES %s
    """

    order_date_start = datetime.now() - timedelta(days=365 * 5)

    for start in range(0, ORDERS_COUNT, CHUNK_SIZE):
        current_chunk_size = min(CHUNK_SIZE, ORDERS_COUNT - start)

        orders_data = [
            (
                order_date_start + timedelta(days=random.randint(0, 365 * 5)),
                random.choice(client_ids),
                random.choice(product_ids),
            )
            for _ in range(current_chunk_size)
        ]

        execute_values(cursor, order_insert_query, orders_data)
        print(f"Inserted {start + current_chunk_size} rows into opt_orders...")

    print("Inserted into opt_orders.")


def main():
    connection = psycopg2.connect(
        host=HOST,
        user=USER,
        password=PASSWORD,
        dbname=DATABASE,
        port=PORT,
    )

    try:
        with connection:
            with connection.cursor() as cursor:
                client_ids = insert_clients(cursor)
                product_ids = insert_products(cursor)
                insert_orders(cursor, client_ids, product_ids)

    finally:
        connection.close()


if __name__ == "__main__":
    main()



