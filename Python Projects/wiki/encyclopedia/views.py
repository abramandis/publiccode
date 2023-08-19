from django.shortcuts import render
from django.shortcuts import redirect
from django.http import HttpResponse
from django.http import HttpResponseRedirect
from django.http import HttpResponseBadRequest
from django.contrib import messages
from django import forms
from django.urls import reverse
import random
import sys
import os
import markdown2

from . import util

class NewTaskForm(forms.Form):
    title = forms.CharField(label="Page Title")
    content = forms.CharField(widget=forms.Textarea(attrs={"rows":5, "cols":20}))
   
def index(request):
    return render(request, "encyclopedia/index.html", {
        "entries": util.list_entries()
    })

def search(request):
    query = request.GET.get('q')
    entries = util.list_entries()
    sublist = []
    for entry in entries :
        if query.lower() == entry.lower() : 
            response = redirect(f'/wiki/{query}')
            return response 

    for entry in entries:
        if query.lower() in entry.lower() :
            sublist.append(entry)

    return render(request, "encyclopedia/search.html", {
         "query": query,
         "matches": sublist
    })

def create(request):

    return render(request, "encyclopedia/create.html", {
        "form": NewTaskForm()
    })

def add(request): 
    if request.method == "POST":
       form = NewTaskForm(request.POST)

    if form.is_valid():
        entries = util.list_entries()
        title = form.cleaned_data["title"]
        content = form.cleaned_data["content"]

        for entry in entries : 
            if title.lower() == entry.lower() :
                return render(request, "encyclopedia/create.html", {
                "form": form,
                "error": "Error! Title already in use."
                })
        # no errors, valid form
        # create new page and save to disk
        util.save_entry(title, content)
        #return HttpResponseRedirect(f"/{title}")
        return gotoentry(request, title)
    else:
        return render(request, "encyclopedia/create.html", {
            "form": form
        })

    return render(request, "encyclopedia/git.html")

def edit(request):
    if request.method == "POST":
       form = NewTaskForm(request.POST)
    if form.is_valid():
        return render(request, "encyclopedia/edit.html", {
            "form": form 
        })
def saveedit(request):
    if request.method == "POST":
       form = NewTaskForm(request.POST)

    if form.is_valid():
        title = form.cleaned_data["title"]
        content = form.cleaned_data["content"]
        # delete old entry in case of title change here 
        # no errors, valid form
        # create/overwrite page and save to disk
        util.save_entry(title, content)
        return gotoentry(request, title)
    else:
        return render(request, "encyclopedia/edit.html", {
            "form": form
        })
    #should never run here 
    return render(request, "encyclopedia/edit.html")

def gotoentry(request, title):
    entry = util.get_entry(f"{title}")
    htmlVersion = markdown2.markdown(entry, extras=['fenced-code-blocks'])

    return render(request, "encyclopedia/entry.html", {
        "entry": entry,
        "title": title.capitalize(), 
        "markdownX": htmlVersion
    })

def randompage(request):
    #entries = util.list_entries()
    #randomindex = random.randint(0, entries.count - 1)
    #title = entries[0]
    #title = "9999.md"
    #return render(request, "encyclopedia/edit.html")
    #return gotoentry(request, title)
    #return render(request, "encyclopedia/index.html", {
    #   "entries": util.list_entries()
    #})
    return render(request, "encyclopedia/create.html", {
        "form": NewTaskForm()
    })

    
    