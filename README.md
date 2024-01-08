# Django-Flutter CRUD Sync

Django-Flutter CRUD Sync est une application permettant de réaliser des opérations CRUD (Create, Read, Update, Delete) sur le frontend Flutter. Les données peuvent être enregistrées localement sur l'appareil à l'aide de SQLite et synchronisées avec un backend Django.

## Fonctionnalités

- Ajout de blogs avec titre et contenu.
- Mise à jour et suppression de blogs.
- Stockage local des blogs avec SQLite.
- Synchronisation des blogs avec un backend Django.

## Technologies utilisées

### Flutter

- [sqflite](https://pub.dev/packages/sqflite) : Package Flutter pour l'accès à la base de données SQLite.
- [http](https://pub.dev/packages/http) : Package Flutter pour les requêtes HTTP.
- [Provider](https://pub.dev/packages/provider) : Gestionnaire d'état pour Flutter.

### Django

- Django Rest Framework (DRF) : Utilisé pour construire l'API REST backend.
- SQLite et MySql : Base de données backend pour stocker les blogs.

## Structure du projet

- `flutter_app/` : Contient le code source de l'application Flutter.
  - ```lua
    lib/
    |-- main.dart
    |-- models/
    |   |-- blog_model.dart
    |-- screens/
    |   |-- blog_editor.dart
    |   |-- blog_add_edit.dart
    |   |-- blog_delete.dart
    |-- database/
    |   |-- db_helper.dart
    |-- services/
    |   |-- connectivity_service.dart
    |-- utils/
    |   |-- constants.dart

```
- `django_app/` : Contient le code source du backend Django.
  - ```lua
    django_app/
    |-- api_blog/
    |   |-- migrations/
    |   |-- __init__.py
    |   |-- admin.py
    |   |-- apps.py
    |   |-- models.py
    |   |-- serializers.py
    |   |-- tests.py
    |   |-- urls.py
    |   |-- views.py
    |
    |-- parameter/
    |   |-- __init__.py
    |   |-- settings.py
    |   |-- urls.py
    |   |-- asgi.py
    |   |-- wsgi.py
    |
    |-- manage.py
    |-- requirements.txt
    |-- README.md

```

## Configuration

1. **Flutter App**

   - Assurez-vous d'avoir Flutter installé. [Guide d'installation Flutter](https://flutter.dev/docs/get-started/install)
   - Naviguez vers le répertoire `flutter_app/`.
   - Exécutez `flutter pub get` pour installer les dépendances.
   - Exécutez l'application avec `flutter run`.

2. **Django App**

   - Assurez-vous d'avoir Python et Django installés.
   - Naviguez vers le répertoire `django_app/`.
   - Exécutez les migrations avec `python manage.py migrate`.
   - Lancez le serveur avec `python manage.py runserver`.

## Utilisation

1. **Ajout d'un blog**

   - Ouvrez l'application Flutter.
     - ![Simulator Screenshot 1.png](image%2FSimulator%20Screenshot%201.png)
   - Appuyez sur le bouton "Add Blog".
     - ![Simulator Screenshot - 22.png](image%2FSimulator%20Screenshot%20-%2022.png)
   - Remplissez les champs et appuyez sur "Save".
     - ![Screenshot_2.png](image%2FScreenshot_2.png)
   - Supprimer un blog
     - ![Simulator Screenshot - 3.png](image%2FSimulator%20Screenshot%20-%203.png)

2. **Synchronisation avec Django Backend**

   - Les blogs ajoutés ou mis à jour sont synchronisés avec le backend Django.
     - ![Screenshot 2024-01-08 at 14.27.23.png](image%2FScreenshot%202024-01-08%20at%2014.27.23.png)
   - Assurez-vous que le backend est en cours d'exécution.
     - ![Screenshot 2024-01-08 at 14.27.48.png](image%2FScreenshot%202024-01-08%20at%2014.27.48.png)

## Contribuer

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir des problèmes, proposer des fonctionnalités ou envoyer des demandes de fusion.


