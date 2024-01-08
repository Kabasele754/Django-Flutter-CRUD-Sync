from django.db import models


# Create your models here.


class Blog(models.Model):
    title = models.CharField(max_length=255)
    content = models.TextField()
    backend_id = models.IntegerField(null=True, blank=True)
    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title

