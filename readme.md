# VARIABLES


## Docker specific

This variable is defined in the file '.env', located at the project root.
Modify this variable to set a custom image name

```
PROJECT_NAME="default"
```

## Django specific variables

Set the default project name. Replace default with your name or leave it as it is.

```
-e PROJECT_NAME="default"
```

Manage the django migrations folder wich are created with manage.py makemigrations.
* Set TRUE to delete the migrations folder before new makemigration runs.

```
-e DELETE_MIGRATIONS=TRUE
```
> NOTE: manage.py makemigrations runs every time the docker container is started.
