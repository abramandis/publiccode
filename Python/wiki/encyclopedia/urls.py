from django.urls import path

from . import views

app_name = "encyclopedia"
urlpatterns = [
    path("", views.index, name="index"),
    path("search", views.search, name="search"),
    path("create", views.create, name="create"),
    path("add", views.add, name="add"),
    path("edit", views.edit, name="edit"),
    path("saveedit", views.saveedit, name="saveedit"),
    path("<str:title>", views.gotoentry, name="gotoentry"),
    path("randompage", views.randompage, name="randompage")
]
