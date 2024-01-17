POSTGRES_PORT_ID = "postgres"
POSTGRES_DB = "app_db"
POSTGRES_USER = "app_user"
POSTGRES_PASSWORD = "password"

POSTGREST_PORT_ID = "http"

def run(plan,
    admin_username="admin",
    admin_password="admin",
):
    """Launches a Nextcloud instance with an attached postgres database.

    Args:
        admin_username (string): The nextcloud admin username
        admin_password (string): The nextcloud admin password
    """
    # Add a Postgres server
    postgres = plan.add_service(
        name = "postgres",
        config = ServiceConfig(
            image = "postgres:15.2-alpine",
            ports = {
                POSTGRES_PORT_ID: PortSpec(5432, application_protocol = "postgresql"),
            },
            env_vars = {
                "POSTGRES_DB": POSTGRES_DB,
                "POSTGRES_USER": POSTGRES_USER,
                "POSTGRES_PASSWORD": POSTGRES_PASSWORD,
            },
        ),
    )

    nextcloud = plan.add_service(
        name = "nextcloud",
        config = ServiceConfig(
            image="sageroom/nextcloud:27.0.2-apache",
            ports={
                "http": PortSpec(
                    number=80,
                    transport_protocol="TCP",
                    application_protocol="http",
                )
            },
            env_vars={
                "POSTGRES_DB": POSTGRES_DB,
                "POSTGRES_USER": POSTGRES_USER,
                "POSTGRES_PASSWORD": POSTGRES_PASSWORD,
                "POSTGRES_HOST": postgres.hostname,
                "NEXTCLOUD_TRUSTED_DOMAINS": "nc.dartoxia.com",
                "TRUSTED_PROXIES": "10.0.0.0/8",
                "PHP_MEMORY_LIMIT":"1000M",
                "NEXTCLOUD_ADMIN_USER": admin_username,
                "NEXTCLOUD_ADMIN_PASSWORD": admin_password
            }
        ),
    )