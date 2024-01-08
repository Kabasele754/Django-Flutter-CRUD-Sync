from django.urls import path
from .views import BlogList, UpdatedBlogList, UnsyncedBlogList

urlpatterns = [
    path('blogs/', BlogList.as_view(), name='blog-list'),
    path('blogs/updated/', UpdatedBlogList.as_view(), name='updated-blog-list'),
    path('blogs/unsynced/', UnsyncedBlogList.as_view(), name='unsynced-blog-list'),
]
