from rest_framework import generics
from .models import Blog
from .serializers import BlogSerializer


class BlogList(generics.ListCreateAPIView):
    queryset = Blog.objects.all()
    serializer_class = BlogSerializer

    def perform_create(self, serializer):
        serializer.save()


class UpdatedBlogList(generics.ListAPIView):
    serializer_class = BlogSerializer

    def get_queryset(self):
        last_sync_time = self.request.GET.get('last_sync_time')
        return Blog.objects.filter(updated__gte=last_sync_time) if last_sync_time else Blog.objects.all()


class UnsyncedBlogList(generics.ListAPIView):
    serializer_class = BlogSerializer

    def get_queryset(self):
        return Blog.objects.filter(backend_id__isnull=True)
