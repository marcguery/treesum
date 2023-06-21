# treesum

Print quickly a tree of folders/files based on the style of `tree` command, showing additionally summarized sizes (recursively including subfolders, unlike `tree`) based on the output of `du`.

# Usage

```
treesum.sh -h
```

# Options

- d (string): directory (default: current).
- p (integer): file tree depth (default: all the way down).
- m (integer): upper size limit in kilob for coloring sizes (default: auto-detect maximal size).
- s (integer): to determine the upper and lower bounds for coloring smallest and biggest sizes; the higher is the scale the smaller are the bins (default: 20).
- a: include files also (default: folders only).
- n: do not show sizes (default: show sizes). In this case `tree` is a better choice!
- o: show very small sizes instead of an upper bound (default: do not show very small sizes).