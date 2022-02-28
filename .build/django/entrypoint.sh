printf "\n \e[1;96m--------------START----------------\e[0m"

printf "\n[$0] Set base dir: $(pwd)"
export BASE_DIR=$(pwd)

# Set the project name
if [ -z $PROJECT_NAME ]; then
    read -p "Enter your project name: " PROJECT_NAME
    printf "\n[$0] Project name set to \e[1;96m$PROJECT_NAME\e[0m"
fi

# Create a project
if [ ! -d $PROJECT_NAME ]; then
    django-admin startproject $PROJECT_NAME
fi
printf "\n[$0] PROJECT_NAME: \e[1;96m$PROJECT_NAME\e[0m"

# Check to remove migrations
if [ $DELETE_MIGRATIONS ];then
    find . -type d -iname migrations -exec rm -Rf "{}" \;
fi
printf "\n[$0] DELETE_MIGRATIONS: \e[1;96m$DELETE_MIGRATIONS\e[0m"

# Customized the settings.py
printf "\n[$0] Modify settings.py"
sed -i "s/ALLOWED_HOST.*=.*/ALLOWED_HOST=${ALLOWED_HOSTS}/" "$PROJECT_NAME/$PROJECT_NAME/settings.py"
sed -i "s/THIRD_PARTY_APPS.*=.*/THIRD_PARTY_APPS=${THIRD_PARTY_APPS}/" "$PROJECT_NAME/$PROJECT_NAME/settings.py"

# Create all defined apps.
printf "\n[$0] APPS: \e[1;96m$THIRD_PARTY_APPS\e[0m"
for app in $(echo $THIRD_PARTY_APPS | sed -r 's/(\o47|"|,|]|\[)//g'); do
    if [ ! -d "$PROJECT_NAME/$app" ];then
        cd $PROJECT_NAME && python "manage.py" startapp $app
    fi
    # Before a makemigration can run. The apps need an entry in the settings.py INSTALLED_APPS list
    cd $BASE_DIR
    python "$PROJECT_NAME/manage.py" makemigrations $app
done

python "$PROJECT_NAME/manage.py" migrate

# This sed syntax is used to replace a whole block of multiline text.
# sed -i "/DATABASES/,/^}/ c TEST" "$PROJECT_NAME/$PROJECT_NAME/settings.py"

# Django commit changes to database.

# Run WSGI application
gunicorn --chdir $PROJECT_NAME "$PROJECT_NAME.wsgi" -b 0.0.0.0:8000 --reload -w 3
# printf "\n[$0] \e[1;96m--------------END----------------\e[0m"
chmod -R 777 $BASE_DIR
