printf "\n[+] \e[1;96m$0\e[0m \n\n"

# Set the project name
if [ -z $PROJECT_NAME ]; then
    read -p "Enter your project name: " PROJECT_NAME
    printf "\n[+] Project name set to \e[1;96m$PROJECT_NAME\e[0m \n\n"
fi

# Create a project
if [ ! -d $PROJECT_NAME ]; then
    django-admin startproject $PROJECT_NAME
fi

# Check to remove migrations
if [ $DELETE_MIGRATIONS -eq true ];then
    find . -type d -iname migrations -exec rm -Rf "{}" \;

# Create all defined apps.
for app in ${APPS[@]};do
    if [ ! -d $PROJECT_NAME/$app ];then
        python "$PROJECT_NAME/manage.py" startapp $app
    fi

    # Django test application for changes.
    python "$PROJECT_NAME/manage.py" makemigrations $app
done

# Django commit changes to database.
python "$PROJECT_NAME/manage.py" migrate

# Run WSGI application
gunicorn --chdir $PROJECT_NAME "$PROJECT_NAME.wsgi" -b 0.0.0.0:8000 --reload -w 3
