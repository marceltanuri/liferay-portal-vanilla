# Liferay DXP - Development Sandbox

This project provisions a complete, containerized development environment for Liferay DXP using Docker and Docker Compose.

The main goal is to provide a "sandbox" with a ready-to-use Liferay stack, simplifying the initial setup and allowing you to focus on developing and testing features on the platform. The environment also includes a mock OAuth 2.0 server to assist with authentication integration tests.

The `Makefile` automates the entire lifecycle of the environment, from building images and applying licenses to shutting down and cleaning up containers.

## Prerequisites

Before you begin, make sure you have `make` installed on your system. Most Unix-based systems (Linux, macOS) already include it. You can check by running:

```sh
make -v
```

## ⚠️ Permission Settings

To ensure the application functions correctly, it is crucial to grant write permissions to all directories and subdirectories from the root of this project. This is necessary to avoid issues with:

- **Log Files**: The application needs permission to create and write to log files.
- **Deployment**: Deployment processes may need to create or modify files.
- **Data Persistence**: If the application saves data to local files (such as SQLite databases, session files, etc.), it will need write permission.

Run the following command in the project root to grant the necessary permissions:

```sh
sudo chmod -R a+w .
```

> **Attention**: This command grants write permission to all users for all files and folders. In a production environment, consider using more restrictive and specific permissions for the directories that actually need them for security reasons.

## How to Use the Makefile

This project uses a `Makefile` to automate common development and deployment tasks. To use it, navigate to the project's root directory and run the `make` commands as described below.

### Available Commands

*   **`make help`**
    Displays a help message with all available targets (commands) in the `Makefile`, along with a brief description of each. It's the quickest way to look up commands directly from the terminal.

    ```sh
    make help
    ```

*   **`make up`**
    This is the main command to build and start the environment. It orchestrates a series of actions:
    1.  **License Check**: Ensures that the license file (`activation-key.xml`) exists in `liferay/license/`.
    2.  **Hotfix Download**: If the `v` (version) and `hotfix` variables are provided, it downloads the corresponding hotfix from the Liferay CDN.
    3.  **Image Build**: Builds (or rebuilds) the Docker images for the services defined in `docker-compose.yml`.
    4.  **Container Initialization**: Starts all services in "detached" mode (in the background).

    **Basic Usage:**
    ```sh
    make up
    ```

    **Usage with Version and Hotfix:**
    You can specify a Liferay version and a hotfix so that the environment is prepared with that exact configuration.

    ```sh
    # Example for Liferay 2024.q2.8 with hotfix 48
    make up v=2024.q2.8 hotfix=48
    ```

    **Usage with Custom Environment:**
    Allows you to start the environment with specific configurations from a directory, including `portal-ext.properties`, environment variables, and OSGi settings.

    ```sh
    # Loads configurations from the /path/to/my-env directory
    make up ENV_DIR=/path/to/my-env
    ```

*   **`make down`**
    Stops and completely removes the Docker environment. This command is destructive and ideal for a full cleanup.
    - Stops and removes the containers.
    - Removes volumes, clearing all persisted data (database, Elasticsearch, etc.).
    - Removes locally built Docker images.
    - Cleans up configuration directories (`liferay/config/.all`, `liferay/config/.custom`), data (`elasticsearch-data`, `liferay/document-library`, `mysql-dump`), and deployment (`liferay/deploy`).

    ```sh
    make down
    ```

*   **`make logs`**
    Displays the logs of one or all containers in real-time.
    
    **For all services:**
    ```sh
    make logs
    ```

    **For a specific service:**
    ```sh
    # Displays logs only for the Liferay container
    make logs liferay
    ```

*   **`make exec`**
    Opens a Bash shell (`/bin/bash`) inside a running container. It is useful for debugging or for running commands directly in the container's environment.

    ```sh
    # Accesses the shell of the Liferay container
    make exec liferay
    ```

*   **`make mfa`**
    Captures and displays the multi-factor authentication (MFA) code directly from the MailHog logs. It is a useful shortcut to speed up login during development.

    ```sh
    make mfa
    ```

*   **`make reset-deploy`**
    Clears the Liferay deployment directory (`liferay/deploy`). This forces Liferay to re-deploy all artifacts on the next startup, which can be useful for resolving cache or deployment issues.

    ```sh
    make reset-deploy
    ```

## Customizing the Environment

The `Makefile` offers a flexible way to customize the development environment through the `ENV_DIR` variable. By pointing this variable to a local directory, you can override or supplement the default Liferay settings, including the database, `document-library`, OSGi modules, and properties.

### Environment Directory Structure

To use this feature, create a directory with the following structure:

```
/your/environment/directory/
├── .args
├── .env
├── config/
│   ├── osgi/
│   │   ├── configs/
│   │   │   └── <your-files>.config
│   │   └── modules/
│   │       └── your-module.jar
│   ├── portal-ext.properties
│   └── tomcat/
│       └── <tomcat-files>
├── document_library/
│   └── ...
└── dump/
    └── dump.sql
```

### Customizable Components

*   **`.args`**: (Required) A file containing the arguments for `make`.

    Example content for the `.args` file:
    ```
    v=2025.q1.8-lts hotfix-48
    ```
    * If this file does not exist, the script will not proceed.
    * The `v` parameter is used to indicate the desired image. If not declared, the script will use the `latest` tag of the Liferay DXP image.
    * The `hotfix` parameter, when declared, indicates the number of the hotfix to be downloaded automatically. The script uses this parameter along with the `v` parameter to automatically assemble the full download link for the hotfix, so when using this parameter, the `v` parameter must be declared correctly.
    
*   **`.env`**: (Optional) A file containing additional environment variables for Docker Compose.

*   **`config/osgi/configs/`**: `.config` configuration files for your OSGi modules.

*   **`config/osgi/modules/`**: Your custom `.jar` modules, which will be copied to the Liferay deployment folder.

*   **`config/portal-ext.properties`**: Custom Liferay properties. The content of this file will be appended to the main `portal-ext.properties`.

*   **`config/tomcat/`**: Tomcat configuration files, such as `web.xml`.

*   **`document_library/`**: The contents of this folder will be copied to the Liferay `document-library`, allowing you to start the environment with pre-existing documents and media.

*   **`dump/dump.sql`**: A MySQL database dump that will be imported on startup, allowing you to start with a pre-populated database.

### How to Use

Pass the path of your environment directory to the `make up` command using the `ENV_DIR` variable:

```sh
make up ENV_DIR=/your/environment/directory/
```

The `Makefile` will automatically detect the files in your directory, merge them with the default settings, and start the environment with your customization.
