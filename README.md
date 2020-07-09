# treesum

Print quickly a tree of folders/files based on the style of `tree` command, showing additionally summarized sizes (recursively including subfolders, unlike `tree`) based on the output of `du`.

# Usage

```
treesum.sh -h
```

# Options

- d (string): directory (default current).
- p (integer): depth (default maximum).
- m (integer): upper size limit in kilob for coloring sizes (default 100000).
- a: include files.
- n: Do not show sizes. In this case `tree` is a better choice (until reaching a huge file tree).